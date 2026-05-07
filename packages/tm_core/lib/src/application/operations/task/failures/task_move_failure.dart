import '../../../../domain/value_objects/task/task_id.dart';

sealed class TaskMoveFailure {
  const TaskMoveFailure();
}

final class TaskMoveNotFound extends TaskMoveFailure {
  const TaskMoveNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskMoveParentNotFound extends TaskMoveFailure {
  const TaskMoveParentNotFound(this.parentId);
  final TaskId parentId;
}

final class TaskMoveSelfParent extends TaskMoveFailure {
  const TaskMoveSelfParent(this.taskId);
  final TaskId taskId;
}

final class TaskMoveWouldCreateCycle extends TaskMoveFailure {
  const TaskMoveWouldCreateCycle(this.taskId);
  final TaskId taskId;
}

final class TaskMoveCrossProject extends TaskMoveFailure {
  const TaskMoveCrossProject({
    required this.taskId,
    required this.parentId,
  });
  final TaskId taskId;
  final TaskId parentId;
}
