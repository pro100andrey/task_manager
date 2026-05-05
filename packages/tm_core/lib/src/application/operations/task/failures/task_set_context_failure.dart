sealed class TaskSetContextFailure {
  const TaskSetContextFailure();
}

final class TaskSetContextNotFound extends TaskSetContextFailure {
  const TaskSetContextNotFound(this.taskId);
  final String taskId;
}

final class TaskSetContextInvalidState extends TaskSetContextFailure {
  const TaskSetContextInvalidState(this.value);
  final String value;
}
