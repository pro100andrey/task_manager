import '../../../../../tm_core.dart';

sealed class ProjectSwitchFailure {
  const ProjectSwitchFailure();
}

final class ProjectSwitchNotFound extends ProjectSwitchFailure {
  const ProjectSwitchNotFound(this.projectId);

  final ProjectId projectId;

  @override
  String toString() => 'ProjectSwitchNotFound(projectId: $projectId)';
}
