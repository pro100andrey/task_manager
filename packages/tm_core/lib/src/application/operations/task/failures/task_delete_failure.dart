import '../../../../../tm_core.dart';

sealed class TaskDeleteFailure {
  const TaskDeleteFailure();
}

final class TaskDeleteNotFound extends TaskDeleteFailure {
  const TaskDeleteNotFound(this.taskId);
  final TaskId taskId;
}
