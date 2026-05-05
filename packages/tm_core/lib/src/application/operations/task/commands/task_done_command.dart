class TaskDoneCommand {
  const TaskDoneCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
