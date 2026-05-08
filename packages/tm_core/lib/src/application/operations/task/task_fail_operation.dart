import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../ports/event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_fail_command.dart';
import 'failures/task_fail_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskFailCommand, Task, TaskFailFailure>;

class TaskFailOperation extends _Operation {
  TaskFailOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final EventBus _bus;

  @override
  String get operationName => 'TaskFailOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskFailCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskFailCommand, TaskFailFailure> preconditionPolicies(
    TaskFailCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskFailCommand, TaskFailFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskFailNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskFailFailure>> run(TaskFailCommand command) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskFailNotFound(command.taskId));
    }

    if (task.status != TaskStatus.inProgress) {
      return Failure(
        TaskFailInvalidTransition(
          from: task.status,
          to: TaskStatus.failed,
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(
      status: TaskStatus.failed,
      statusReason: command.reason,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    await _bus.publish(
      TaskFailedEvent(taskId: saved.id, reason: command.reason),
    );

    return Success(saved);
  }
}
