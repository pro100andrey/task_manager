import '../../../domain/entities/task.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_move_command.dart';
import 'failures/task_move_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskMoveCommand, Task, TaskMoveFailure>;

class TaskMoveOperation extends _Operation {
  TaskMoveOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskMoveOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskMoveCommand command) => {
    'taskId': command.taskId,
    'newParentId': command.newParentId,
  };

  @override
  OperationPolicySet<TaskMoveCommand, TaskMoveFailure> preconditionPolicies(
    TaskMoveCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskMoveCommand, TaskMoveFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskMoveNotFound.new,
    ),
  ]);

  @override
  Future<Result<Task, TaskMoveFailure>> run(TaskMoveCommand command) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskMoveNotFound(command.taskId));
    }

    TaskId? newParentId;

    if (command.newParentId != null) {
      // Validate and resolve parent
      late final TaskId rawNewParentId;
      try {
        rawNewParentId = command.newParentId!;
      } on FormatException {
        return Failure(TaskMoveParentNotFound(command.newParentId!));
      }

      // Self-parent guard
      if (rawNewParentId == task.id) {
        return Failure(TaskMoveSelfParent(command.taskId));
      }

      final parent = await _repository.getById(rawNewParentId);
      if (parent == null) {
        return Failure(TaskMoveParentNotFound(command.newParentId!));
      }

      // Cross-project guard
      if (parent.projectId != task.projectId) {
        return Failure(
          TaskMoveCrossProject(
            taskId: command.taskId,
            parentId: command.newParentId!,
          ),
        );
      }

      // Cycle guard: the new parent must not be a descendant of the task
      if (await _isDescendant(task.id, rawNewParentId)) {
        return Failure(TaskMoveWouldCreateCycle(command.taskId));
      }

      newParentId = rawNewParentId;
    }

    final now = DateTime.now().toUtc();
    final updated = task.copyWith(parentId: newParentId, updatedAt: now);
    final saved = await _repository.save(updated);

    await _bus.publish(
      DomainEvent.taskMoved(taskId: saved.id, newParentId: newParentId),
    );

    return Success(saved);
  }

  /// Returns true if [candidate] is a descendant of [ancestor].
  Future<bool> _isDescendant(TaskId ancestor, TaskId candidate) async {
    var current = candidate;
    // Walk up the parent chain from candidate.
    final visited = <TaskId>{};
    while (true) {
      if (current == ancestor) {
        return true;
      }
      if (visited.contains(current)) {
        return false; // cycle safety
      }
      visited.add(current);
      final t = await _repository.getById(current);
      if (t?.parentId == null) {
        return false;
      }
      current = t!.parentId!;
    }
  }
}
