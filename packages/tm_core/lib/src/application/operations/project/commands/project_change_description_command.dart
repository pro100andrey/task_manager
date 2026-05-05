class ProjectChangeDescriptionCommand {
  const ProjectChangeDescriptionCommand({
    required this.projectId,
    this.description,
  });

  final String projectId;
  final String? description;
}
