sealed class ProjectCreateFailure {
  const ProjectCreateFailure();
}

final class ProjectCreateNameAlreadyExists extends ProjectCreateFailure {
  const ProjectCreateNameAlreadyExists(this.name);

  final String name;
}

final class ProjectCreateInvalidName extends ProjectCreateFailure {
  const ProjectCreateInvalidName(this.reason);

  final String reason;
}

final class ProjectCreateInvalidDescription extends ProjectCreateFailure {
  const ProjectCreateInvalidDescription(this.reason);

  final String reason;
}
