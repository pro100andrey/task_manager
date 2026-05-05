import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_hold_command.dart';
import 'failures/task_hold_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskHoldCommand, Task, TaskHoldFailure>;

class TaskHoldOperation extends _Operation {
  TaskHoldOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskHoldOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskHoldCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskHoldCommand, TaskHoldFailure> preconditionPolicies(
    TaskHoldCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskHoldCommand, TaskHoldFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskHoldNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskHoldFailure>> run(TaskHoldCommand command) async {
    final task = await _repository.getById(TaskId(command.taskId));
    if (task == null) {
      return Failure(TaskHoldNotFound(command.taskId));
    }

    if (task.status != TaskStatus.inProgress) {
      return Failure(
        TaskHoldInvalidTransition(
          from: task.status.value,
          to: TaskStatus.onHold.value,
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(
      status: TaskStatus.onHold,
      statusReason: command.reason,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    await _bus.publish(
      TaskPutOnHoldEvent(taskId: saved.id, reason: command.reason),
    );

    return Success(saved);
  }
}
