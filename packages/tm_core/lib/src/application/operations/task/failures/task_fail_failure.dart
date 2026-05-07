import '../../../../../tm_core.dart';

sealed class TaskFailFailure {
  const TaskFailFailure();
}

final class TaskFailNotFound extends TaskFailFailure {
  const TaskFailNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskFailInvalidTransition extends TaskFailFailure {
  const TaskFailInvalidTransition({required this.from, required this.to});
  final TaskStatus from;
  final TaskStatus to;
}
