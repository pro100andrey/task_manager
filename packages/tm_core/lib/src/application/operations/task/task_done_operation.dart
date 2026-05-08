import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../events/event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_done_command.dart';
import 'failures/task_done_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskDoneCommand, Task, TaskDoneFailure>;

class TaskDoneOperation extends _Operation {
  TaskDoneOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final EventBus _bus;

  @override
  String get operationName => 'TaskDoneOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskDoneCommand command) => {
    'taskId': command.taskId,
  };

  @override
  PolicySet<TaskDoneCommand, TaskDoneFailure> preconditionPolicies(
    TaskDoneCommand command,
    OperationContext context,
  ) => PolicySet([
    TaskExistsPolicy(_repository, (cmd) => cmd.taskId, TaskDoneNotFound.new),
  ]);

  @override
  Future<Result<Task, TaskDoneFailure>> run(TaskDoneCommand command) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskDoneNotFound(command.taskId));
    }

    if (task.status != TaskStatus.inProgress) {
      return Failure(
        TaskDoneInvalidTransition(
          from: task.status.value,
          to: TaskStatus.completed.value,
        ),
      );
    }

    final projectTasks = await _repository.getByProjectId(task.projectId);
    if (!isCompletable(task, projectTasks)) {
      return Failure(TaskDoneNotCompletable(command.taskId));
    }

    final now = DateTime.now().toUtc();
    final tasksById = {for (final item in projectTasks) item.id: item};
    final lineage = <Task>[];
    Task? current = task;
    while (current != null) {
      lineage.add(current);
      current = current.parentId != null ? tasksById[current.parentId!] : null;
    }

    final updated = task.copyWith(
      status: TaskStatus.completed,
      statusReason: command.reason,
      lastProgressAt: now,
      completedAt: now,
      metadata: incrementTaskPnrCompleted(task),
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    for (final ancestor in lineage.skip(1)) {
      final updatedAncestor = ancestor.copyWith(
        metadata: incrementTaskPnrCompleted(ancestor),
        updatedAt: now,
      );
      await _repository.save(updatedAncestor);
    }
    await _bus.publish(TaskCompletedEvent(taskId: saved.id));

    return Success(saved);
  }
}
