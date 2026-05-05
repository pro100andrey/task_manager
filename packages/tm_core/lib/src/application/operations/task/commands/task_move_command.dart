class TaskMoveCommand {
  const TaskMoveCommand({required this.taskId, this.newParentId});

  final String taskId;

  /// null = make the task a root task.
  final String? newParentId;
}
