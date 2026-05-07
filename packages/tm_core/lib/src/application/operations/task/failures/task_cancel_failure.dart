import '../../../../../tm_core.dart';

sealed class TaskCancelFailure {
  const TaskCancelFailure();
}

final class TaskCancelNotFound extends TaskCancelFailure {
  const TaskCancelNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskCancelInvalidTransition extends TaskCancelFailure {
  const TaskCancelInvalidTransition({required this.from, required this.to});
  final TaskStatus from;
  final TaskStatus to;
}
