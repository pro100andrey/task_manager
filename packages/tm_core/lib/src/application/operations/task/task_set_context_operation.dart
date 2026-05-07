import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_set_context_command.dart';
import 'failures/task_set_context_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation =
    Operation<TaskSetContextCommand, Task, TaskSetContextFailure>;

class TaskSetContextOperation extends _Operation {
  TaskSetContextOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskSetContextOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskSetContextCommand command) => {
    'taskId': command.taskId,
    'contextState': command.contextState,
  };

  @override
  OperationPolicySet<TaskSetContextCommand, TaskSetContextFailure>
  preconditionPolicies(
    TaskSetContextCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskSetContextCommand, TaskSetContextFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskSetContextNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskSetContextFailure>> run(
    TaskSetContextCommand command,
  ) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskSetContextNotFound(command.taskId));
    }

    final contextState = TaskContextState.values
        .where((s) => s.value == command.contextState)
        .firstOrNull;
    if (contextState == null) {
      return Failure(TaskSetContextInvalidState(command.contextState));
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(contextState: contextState, updatedAt: now);
    final saved = await _repository.save(updated);

    await _bus.publish(
      DomainEvent.taskContextChanged(
        taskId: saved.id,
        contextState: contextState.value,
      ),
    );

    return Success(saved);
  }
}
