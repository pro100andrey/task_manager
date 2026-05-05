import 'package:collection/collection.dart';

import '../../application/ports/project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/exceptions/project_exceptions.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/project/project_ref.dart';

final class MemProjectsRepositoryImpl implements ProjectRepository {
  final _storage = <ProjectId, Project>{};
  ProjectId? _currentProjectId;

  @override
  Future<Project?> getByRef(ProjectRef ref) async {
    switch (ref) {
      case ProjectIdRef(:final id):
        return _storage[id];
      case ProjectNameRef(:final name):
        return _storage.values.firstWhereOrNull((p) => p.name == name);
    }
  }

  @override
  Future<Project> save(Project project) async {
    _storage[project.id] = project;

    return project;
  }

  @override
  Future<List<Project>> getAllProjects() async =>
      UnmodifiableListView(_storage.values);

  @override
  Future<Project?> getById(ProjectId id) async => _storage[id];

  @override
  Future<Project?> getCurrentProject() async {
    if (_currentProjectId == null) {
      return null;
    }

    return _storage[_currentProjectId!];
  }

  @override
  Future<Project> switchCurrentProject(ProjectId id) async {
    final project = _storage[id];
    if (project == null) {
      throw ProjectNotFound(id.value);
    }

    _currentProjectId = id;

    return project;
  }

  @override
  Future<void> delete(ProjectId id) async {
    if (!_storage.containsKey(id)) {
      throw ProjectNotFound(id.value);
    }

    _storage.remove(id);
    
    if (_currentProjectId == id) {
      _currentProjectId = null;
    }
  }
}
