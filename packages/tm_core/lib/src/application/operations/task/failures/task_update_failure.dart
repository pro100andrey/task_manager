import '../../../../../tm_core.dart';

sealed class TaskUpdateFailure {
  const TaskUpdateFailure();
}

final class TaskUpdateNotFound extends TaskUpdateFailure {
  const TaskUpdateNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskUpdateInvalidTitle extends TaskUpdateFailure {
  const TaskUpdateInvalidTitle(this.reason);
  final String reason;
}

final class TaskUpdateInvalidDescription extends TaskUpdateFailure {
  const TaskUpdateInvalidDescription(this.reason);
  final String reason;
}

final class TaskUpdateInvalidBusinessValue extends TaskUpdateFailure {
  const TaskUpdateInvalidBusinessValue(this.value);
  final int value;
}

final class TaskUpdateInvalidUrgencyScore extends TaskUpdateFailure {
  const TaskUpdateInvalidUrgencyScore(this.value);
  final int value;
}
