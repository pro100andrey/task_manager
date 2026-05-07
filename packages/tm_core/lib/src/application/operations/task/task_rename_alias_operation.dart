import '../../../domain/entities/task.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
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
    'alias': command.alias?.normalized,
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
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskRenameAliasNotFound(command.taskId));
    }

    final now = DateTime.now().toUtc();

    // Clearing alias
    if (command.alias == null) {
      final updated = task.copyWith(
        alias: null,
        updatedAt: now,
      );
      final saved = await _repository.save(updated);
      await _bus.publish(
        DomainEvent.taskAliasRenamed(taskId: saved.id),
      );
      return Success(saved);
    }

    // Uniqueness check within project
    final existing = await _repository.getByAlias(
      task.projectId,
      command.alias!,
    );
    if (existing != null && existing.id != task.id) {
      return Failure(TaskRenameAliasAlreadyExists(command.alias!));
    }

    final updated = task.copyWith(
      alias: command.alias,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);

    await _bus.publish(
      DomainEvent.taskAliasRenamed(
        taskId: saved.id,
        newAlias: command.alias,
      ),
    );

    return Success(saved);
  }
}
