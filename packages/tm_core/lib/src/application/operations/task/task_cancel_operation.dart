import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_cancel_command.dart';
import 'failures/task_cancel_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskCancelCommand, Task, TaskCancelFailure>;

class TaskCancelOperation extends _Operation {
  TaskCancelOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskCancelOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskCancelCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskCancelCommand, TaskCancelFailure> preconditionPolicies(
    TaskCancelCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskCancelCommand, TaskCancelFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskCancelNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskCancelFailure>> run(
    TaskCancelCommand command,
  ) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskCancelNotFound(command.taskId));
    }

    if (task.status.isTerminal) {
      return Failure(
        TaskCancelInvalidTransition(
          from: task.status,
          to: TaskStatus.cancelled,
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(
      status: TaskStatus.cancelled,
      statusReason: command.reason,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    await _bus.publish(
      TaskCancelledEvent(taskId: saved.id, reason: command.reason),
    );

    return Success(saved);
  }
}
