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
import 'commands/task_start_command.dart';
import 'failures/task_start_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskStartCommand, Task, TaskStartFailure>;

class TaskStartOperation extends _Operation {
  TaskStartOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskStartOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskStartCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskStartCommand, TaskStartFailure> preconditionPolicies(
    TaskStartCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskStartCommand, TaskStartFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskStartNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskStartFailure>> run(TaskStartCommand command) async {
    final task = await _repository.getById(TaskId(command.taskId));
    if (task == null) {
      return Failure(TaskStartNotFound(command.taskId));
    }

    const validFrom = {TaskStatus.pending, TaskStatus.onHold};
    if (!validFrom.contains(task.status)) {
      return Failure(
        TaskStartInvalidTransition(
          from: task.status.value,
          to: TaskStatus.inProgress.value,
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(
      status: TaskStatus.inProgress,
      statusReason: command.reason,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    await _bus.publish(TaskStartedEvent(taskId: saved.id));

    return Success(saved);
  }
}
