class TaskLinkAddCommand {
  const TaskLinkAddCommand({
    required this.fromTaskId,
    required this.toTaskId,
    required this.linkType,
    this.label,
  });

  final String fromTaskId;
  final String toTaskId;
  final String linkType;
  final String? label;
}
