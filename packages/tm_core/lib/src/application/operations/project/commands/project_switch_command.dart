import '../../../../../tm_core.dart';
import '../../command.dart';

class ProjectSwitchCommand extends Command {
  const ProjectSwitchCommand({required this.projectId});

  final ProjectId projectId;
}
