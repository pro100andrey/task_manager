sealed class TaskDoneFailure {
  const TaskDoneFailure();
}

final class TaskDoneNotFound extends TaskDoneFailure {
  const TaskDoneNotFound(this.taskId);
  final String taskId;
}

final class TaskDoneInvalidTransition extends TaskDoneFailure {
  const TaskDoneInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}

final class TaskDoneNotCompletable extends TaskDoneFailure {
  const TaskDoneNotCompletable(this.taskId);
  final String taskId;
}
