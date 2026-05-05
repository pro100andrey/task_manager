import '../../command.dart';

class ProjectSwitchCommand extends Command {
  const ProjectSwitchCommand({required this.projectId});

  final String projectId;
}
