import '../../../../domain/value_objects/value_objects.dart';
import '../../command.dart';

class ProjectUpdateCommand extends Command {
  const ProjectUpdateCommand({
    required this.projectId,
    this.name,
    this.description,
  });

  final ProjectId projectId;
  final ProjectName? name;
  final ProjectDescription? description;
}
