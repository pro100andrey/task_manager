sealed class ProjectMutationFailure {
  const ProjectMutationFailure();
}

final class ProjectMutationNotFound extends ProjectMutationFailure {
  const ProjectMutationNotFound(this.ref);

  final String ref;

  @override
  String toString() => 'ProjectMutationNotFound(ref: $ref)';
}

final class ProjectMutationNameAlreadyExists extends ProjectMutationFailure {
  const ProjectMutationNameAlreadyExists(this.name);

  final String name;

  @override
  String toString() => 'ProjectMutationNameAlreadyExists(name: $name)';
}
