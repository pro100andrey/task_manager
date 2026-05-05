class TaskLinkRemoveCommand {
  const TaskLinkRemoveCommand({
    required this.fromTaskId,
    required this.toTaskId,
    this.linkType,
  });

  final String fromTaskId;
  final String toTaskId;

  /// If null, removes all link types between the two tasks.
  final String? linkType;
}
