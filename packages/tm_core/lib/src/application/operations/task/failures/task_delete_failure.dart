sealed class TaskDeleteFailure {
  const TaskDeleteFailure();
}

final class TaskDeleteNotFound extends TaskDeleteFailure {
  const TaskDeleteNotFound(this.taskId);
  final String taskId;
}
