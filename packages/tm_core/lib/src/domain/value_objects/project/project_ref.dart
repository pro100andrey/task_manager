import '../value_objects.dart';

/// A sealed class to represent a reference to a project, which can be either
/// by ID or by name.
sealed class ProjectRef {
  const ProjectRef();

  /// Factory constructor to create a ProjectRef from a ProjectId.
  factory ProjectRef.id(ProjectId id) = ProjectIdRef;

  /// Factory constructor to create a ProjectRef from a ProjectName.
  factory ProjectRef.name(ProjectName name) = ProjectNameRef;

  @override
  String toString() => switch (this) {
    ProjectIdRef(:final id) => 'Project ID: $id',
    ProjectNameRef(:final name) => 'Project Name: $name',
  };

  // Helper getters to check the type of reference.
  bool get isId => this is ProjectIdRef;

  // Helper getters to check the type of reference.
  bool get isName => this is ProjectNameRef;

  // ProjectId? get maybeId => switch (this) {
  //   _ProjectIdRef(:final id) => id,
  //   _ => null,
  // };

  // ProjectName? get maybeName => switch (this) {
  //   _ProjectNameRef(:final name) => name,
  //   _ => null,
  // };

  String get value => switch (this) {
    ProjectIdRef(:final id) => id.value,
    ProjectNameRef(:final name) => name.value,
  };
}

class ProjectIdRef extends ProjectRef {
  const ProjectIdRef(this.id);

  final ProjectId id;
}

class ProjectNameRef extends ProjectRef {
  const ProjectNameRef(this.name);

  final ProjectName name;
}
