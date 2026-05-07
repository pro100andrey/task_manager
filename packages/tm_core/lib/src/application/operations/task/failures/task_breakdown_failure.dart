import '../../../../../tm_core.dart';

sealed class TaskBreakdownFailure {
  const TaskBreakdownFailure(this.code, this.message);

  final String code;
  final String message;
}

class TaskBreakdownNotFound extends TaskBreakdownFailure {
  const TaskBreakdownNotFound(TaskId taskId)
    : super('TASK_NOT_FOUND', 'Task not found: $taskId');
}

class TaskBreakdownValidationError extends TaskBreakdownFailure {
  const TaskBreakdownValidationError(String message)
    : super('REPLAN_VALIDATION_ERROR', message);
}

class TaskBreakdownStallDetected extends TaskBreakdownFailure {
  const TaskBreakdownStallDetected(String message)
    : super('STALL_DETECTED', message);
}
