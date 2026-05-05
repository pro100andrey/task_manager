import '../../../domain/entities/task.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/task_exceptions.dart';
import '../../../domain/result.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/task/task_alias.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_rename_alias_command.dart';
import 'failures/task_rename_alias_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation =
    Operation<TaskRenameAliasCommand, Task, TaskRenameAliasFailure>;

class TaskRenameAliasOperation extends _Operation {
  TaskRenameAliasOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskRenameAliasOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskRenameAliasCommand command) => {
    'taskId': command.taskId,
    'alias': command.alias,
  };

  @override
  OperationPolicySet<TaskRenameAliasCommand, TaskRenameAliasFailure>
  preconditionPolicies(
    TaskRenameAliasCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskRenameAliasCommand, TaskRenameAliasFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskRenameAliasNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskRenameAliasFailure>> run(
    TaskRenameAliasCommand command,
  ) async {
    final task = await _repository.getById(TaskId(command.taskId));
    if (task == null) {
      return Failure(TaskRenameAliasNotFound(command.taskId));
    }

    final now = DateTime.now().toUtc();

    // Clearing alias
    if (command.alias == null) {
      final updated = task.copyWith(
        alias: null,
        normalizedAlias: null,
        updatedAt: now,
      );
      final saved = await _repository.save(updated);
      await _bus.publish(
        DomainEvent.taskAliasRenamed(taskId: saved.id, newAlias: ''),
      );
      return Success(saved);
    }

    // Normalize alias
    String normalized;
    try {
      normalized = normalizeAlias(command.alias!);
    } on InvalidAliasException catch (e) {
      return Failure(TaskRenameAliasInvalidAlias(e.reason));
    }

    final aliasVo = TaskAlias(normalized);

    // Uniqueness check within project
    final existing = await _repository.getByAlias(task.projectId, aliasVo);
    if (existing != null && existing.id != task.id) {
      return Failure(TaskRenameAliasAlreadyExists(normalized));
    }

    final updated = task.copyWith(
      alias: aliasVo,
      normalizedAlias: normalized,
      updatedAt: now,
    );
    final saved = await _repository.save(updated);

    await _bus.publish(
      DomainEvent.taskAliasRenamed(taskId: saved.id, newAlias: normalized),
    );

    return Success(saved);
  }
}
