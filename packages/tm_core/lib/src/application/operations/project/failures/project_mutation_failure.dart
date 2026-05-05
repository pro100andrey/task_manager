import '../../../../../tm_core.dart';

sealed class ProjectMutationFailure {
  const ProjectMutationFailure();
}

final class ProjectMutationNotFound extends ProjectMutationFailure {
  const ProjectMutationNotFound(this.projectId);

  final ProjectId projectId;

  @override
  String toString() => 'ProjectMutationNotFound(projectId: $projectId)';
}

final class ProjectMutationNameAlreadyExists extends ProjectMutationFailure {
  const ProjectMutationNameAlreadyExists(this.name);

  final ProjectName name;

  @override
  String toString() => 'ProjectMutationNameAlreadyExists(name: $name)';
}
