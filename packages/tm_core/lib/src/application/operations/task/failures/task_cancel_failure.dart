sealed class TaskCancelFailure {
  const TaskCancelFailure();
}

final class TaskCancelNotFound extends TaskCancelFailure {
  const TaskCancelNotFound(this.taskId);
  final String taskId;
}

final class TaskCancelInvalidTransition extends TaskCancelFailure {
  const TaskCancelInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}
