sealed class ProjectSwitchFailure {
  const ProjectSwitchFailure();
}

final class ProjectSwitchNotFound extends ProjectSwitchFailure {
  const ProjectSwitchNotFound(this.ref);

  final String ref;
}
