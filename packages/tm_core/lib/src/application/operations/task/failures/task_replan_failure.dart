import '../../../../../tm_core.dart';

sealed class TaskReplanFailure {
  const TaskReplanFailure(this.code, this.message);

  final String code;
  final String message;
}

class TaskReplanNotFound extends TaskReplanFailure {
  const TaskReplanNotFound(TaskId taskId)
    : super('TASK_NOT_FOUND', 'Task not found: $taskId');
}

class TaskReplanValidationError extends TaskReplanFailure {
  const TaskReplanValidationError(String message)
    : super('REPLAN_VALIDATION_ERROR', message);
}

class TaskReplanStallDetected extends TaskReplanFailure {
  const TaskReplanStallDetected(String message)
    : super('STALL_DETECTED', message);
}

class TaskReplanCycleDetected extends TaskReplanFailure {
  const TaskReplanCycleDetected(this.path)
    : super('STRONG_CYCLE_DETECTED', 'Strong cycle detected: $path');

  final List<TaskId> path;
}
