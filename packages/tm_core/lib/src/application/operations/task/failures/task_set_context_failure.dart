import '../../../../../tm_core.dart';

sealed class TaskSetContextFailure {
  const TaskSetContextFailure();
}

final class TaskSetContextNotFound extends TaskSetContextFailure {
  const TaskSetContextNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskSetContextInvalidState extends TaskSetContextFailure {
  const TaskSetContextInvalidState(this.value);
  final String value;
}
