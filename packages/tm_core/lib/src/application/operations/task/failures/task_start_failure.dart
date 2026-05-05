sealed class TaskStartFailure {
  const TaskStartFailure();
}

final class TaskStartNotFound extends TaskStartFailure {
  const TaskStartNotFound(this.taskId);
  final String taskId;
}

final class TaskStartInvalidTransition extends TaskStartFailure {
  const TaskStartInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}
