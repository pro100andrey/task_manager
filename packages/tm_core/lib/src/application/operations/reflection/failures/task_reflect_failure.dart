sealed class TaskReflectFailure {
  const TaskReflectFailure(this.code, this.message);

  final String code;
  final String message;
}

class TaskReflectTaskNotFound extends TaskReflectFailure {
  const TaskReflectTaskNotFound(String taskId)
    : super('TASK_NOT_FOUND', 'Task not found: $taskId');
}

class TaskReflectProjectNotFound extends TaskReflectFailure {
  const TaskReflectProjectNotFound()
    : super('TASK_NOT_FOUND', 'Project context not found for reflection');
}

class TaskReflectInvalidContent extends TaskReflectFailure {
  const TaskReflectInvalidContent(String message)
    : super('INVALID_CONTENT', message);
}

class TaskReflectInvalidBudget extends TaskReflectFailure {
  const TaskReflectInvalidBudget(int budget)
    : super(
        'INVALID_REFLECTION_BUDGET',
        'Reflection budget must be positive: $budget',
      );
}

class TaskReflectBudgetExceeded extends TaskReflectFailure {
  const TaskReflectBudgetExceeded(String message)
    : super('RECURSIVE_REFLECTION_WARNING', message);
}

class TaskReflectReplanTaskCreateFailed extends TaskReflectFailure {
  const TaskReflectReplanTaskCreateFailed(String message)
    : super('REPLAN_TASK_CREATE_FAILED', message);
}
