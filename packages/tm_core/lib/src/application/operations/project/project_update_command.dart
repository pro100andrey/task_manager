class ProjectUpdateCommand {
  const ProjectUpdateCommand({
    required this.projectId,
    this.name,
    this.description,
  }) : assert(
         name != null || description != null,
         'At least one field (name or description) must be provided.',
       );

  final String projectId;
  final String? name;
  final String? description;
}
