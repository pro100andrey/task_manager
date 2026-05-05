sealed class TaskHoldFailure {
  const TaskHoldFailure();
}

final class TaskHoldNotFound extends TaskHoldFailure {
  const TaskHoldNotFound(this.taskId);
  final String taskId;
}

final class TaskHoldInvalidTransition extends TaskHoldFailure {
  const TaskHoldInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}
