class TaskCancelCommand {
  const TaskCancelCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
