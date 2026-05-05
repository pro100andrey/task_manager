import '../../../../../tm_core.dart';

sealed class ProjectMutationFailure {
  const ProjectMutationFailure();
}

final class ProjectMutationNotFound extends ProjectMutationFailure {
  const ProjectMutationNotFound(this.id);

  final ProjectId id;

  @override
  String toString() => 'ProjectMutationNotFound(id: $id)';
}

final class ProjectMutationNameAlreadyExists extends ProjectMutationFailure {
  const ProjectMutationNameAlreadyExists(this.name);

  final ProjectName name;

  @override
  String toString() => 'ProjectMutationNameAlreadyExists(name: $name)';
}
