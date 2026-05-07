import '../../../../../tm_core.dart';

sealed class TaskHoldFailure {
  const TaskHoldFailure();
}

final class TaskHoldNotFound extends TaskHoldFailure {
  const TaskHoldNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskHoldInvalidTransition extends TaskHoldFailure {
  const TaskHoldInvalidTransition({required this.from, required this.to});
  final TaskStatus from;
  final TaskStatus to;
}
