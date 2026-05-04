import '../value_objects.dart';

/// A sealed class to represent a reference to a project, which can be either
/// by ID or by name.
sealed class ProjectRef {
  const ProjectRef();

  /// Factory constructor to create a ProjectRef from a ProjectId.
  factory ProjectRef.id(ProjectId id) = _ProjectIdRef;

  /// Factory constructor to create a ProjectRef from a ProjectName.
  factory ProjectRef.name(ProjectName name) = _ProjectNameRef;

  @override
  String toString() => switch (this) {
    _ProjectIdRef(:final id) => 'Project ID: $id',
    _ProjectNameRef(:final name) => 'Project Name: $name',
  };

  // Helper getters to check the type of reference.
  bool get isId => this is _ProjectIdRef;

  // Helper getters to check the type of reference.
  bool get isName => this is _ProjectNameRef;

  ProjectId? get maybeId => switch (this) {
    _ProjectIdRef(:final id) => id,
    _ => null,
  };

  ProjectName? get maybeName => switch (this) {
    _ProjectNameRef(:final name) => name,
    _ => null,
  };

  ProjectId get id => switch (this) {
    _ProjectIdRef(:final id) => id,
    _ => throw StateError('Not a Project ID reference'),
  };

  ProjectName get name => switch (this) {
    _ProjectNameRef(:final name) => name,
    _ => throw StateError('Not a Project Name reference'),
  };

  String get value => switch (this) {
    _ProjectIdRef(:final id) => id.value,
    _ProjectNameRef(:final name) => name.value,
  };
}

class _ProjectIdRef extends ProjectRef {
  const _ProjectIdRef(this.id);
  @override
  final ProjectId id;
}

class _ProjectNameRef extends ProjectRef {
  const _ProjectNameRef(this.name);
  @override
  final ProjectName name;
}
