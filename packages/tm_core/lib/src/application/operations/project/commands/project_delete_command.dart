import '../../../../domain/value_objects/value_objects.dart';
import '../../command.dart';

class ProjectDeleteCommand extends Command {
  const ProjectDeleteCommand({required this.projectId});

  final ProjectId projectId;
}
