import '../../../../domain/value_objects/project/project_description.dart';
import '../../../../domain/value_objects/project/project_name.dart';
import '../../command.dart';

class ProjectCreateCommand extends Command {
  const ProjectCreateCommand({required this.name, this.description});

  final ProjectName name;
  final ProjectDescription? description;
}
