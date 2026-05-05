import '../../../../../tm_core.dart';
import '../../command.dart';

class ProjectRenameCommand extends Command {
  const ProjectRenameCommand({
    required this.projectId,
    required this.newName,
  });

  final ProjectId projectId;
  final ProjectName newName;
}
