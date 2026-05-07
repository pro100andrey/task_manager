import '../../../../../tm_core.dart';

sealed class TaskStartFailure {
  const TaskStartFailure();
}

final class TaskStartNotFound extends TaskStartFailure {
  const TaskStartNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskStartInvalidTransition extends TaskStartFailure {
  const TaskStartInvalidTransition({required this.from, required this.to});
  final TaskStatus from;
  final TaskStatus to;
}
