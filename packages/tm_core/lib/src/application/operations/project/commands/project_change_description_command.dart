import '../../../../domain/value_objects/value_objects.dart';
import '../../command.dart';

class ProjectChangeDescriptionCommand extends Command {
  const ProjectChangeDescriptionCommand({
    required this.projectId,
    this.description,
  });

  /// The unique identifier of the project to update.
  final ProjectId projectId;

  /// The new description for the project. If null, the description will not be
  /// changed.
  final ProjectDescription? description;
}
