sealed class ProjectDeleteFailure {
  const ProjectDeleteFailure();
}

final class ProjectDeleteNotFound extends ProjectDeleteFailure {
  const ProjectDeleteNotFound(this.ref);

  final String ref;
}
