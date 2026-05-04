class ProjectNotFound implements Exception {
  const ProjectNotFound(this.ref);
  final String ref;
}

class ProjectNameAlreadyExists implements Exception {
  const ProjectNameAlreadyExists(this.name);
  final String name;
}
