import '../../../../domain/value_objects/value_objects.dart';
import '../../command.dart';

class ProjectChangeDescriptionCommand extends Command {
  const ProjectChangeDescriptionCommand({
    required this.projectId,
    this.description,
  });

  final ProjectId projectId;
  final ProjectDescription? description;
}
