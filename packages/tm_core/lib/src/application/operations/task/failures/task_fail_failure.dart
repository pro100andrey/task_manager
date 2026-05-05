sealed class TaskFailFailure {
  const TaskFailFailure();
}

final class TaskFailNotFound extends TaskFailFailure {
  const TaskFailNotFound(this.taskId);
  final String taskId;
}

final class TaskFailInvalidTransition extends TaskFailFailure {
  const TaskFailInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}
