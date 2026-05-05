class TaskRenameAliasCommand {
  const TaskRenameAliasCommand({required this.taskId, this.alias});

  final String taskId;

  /// null = clear the alias.
  final String? alias;
}
