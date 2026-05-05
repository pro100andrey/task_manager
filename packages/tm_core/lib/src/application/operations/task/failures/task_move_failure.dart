sealed class TaskMoveFailure {
  const TaskMoveFailure();
}

final class TaskMoveNotFound extends TaskMoveFailure {
  const TaskMoveNotFound(this.taskId);
  final String taskId;
}

final class TaskMoveParentNotFound extends TaskMoveFailure {
  const TaskMoveParentNotFound(this.parentId);
  final String parentId;
}

final class TaskMoveSelfParent extends TaskMoveFailure {
  const TaskMoveSelfParent(this.taskId);
  final String taskId;
}

final class TaskMoveWouldCreateCycle extends TaskMoveFailure {
  const TaskMoveWouldCreateCycle(this.taskId);
  final String taskId;
}

final class TaskMoveCrossProject extends TaskMoveFailure {
  const TaskMoveCrossProject({
    required this.taskId,
    required this.parentId,
  });
  final String taskId;
  final String parentId;
}
