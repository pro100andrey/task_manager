import 'package:collection/collection.dart';

import '../../application/repositories/project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/exceptions/project_exceptions.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/project/project_ref.dart';

final class MemProjectsRepositoryImpl implements ProjectRepository {
  final _storage = <ProjectId, Project>{};
  ProjectId? _currentProjectId;

  @override
  Future<Project?> getByRef(ProjectRef ref) async {
    final id = ref.maybeId;
    if (id != null) {
      return _storage[id];
    }

    final name = ref.maybeName;
    if (name != null) {
      return _storage.values.firstWhereOrNull((p) => p.name == name);
    }

    return null;
  }

  @override
  Future<Project> save(Project project) async {
    _storage[project.id] = project;
    return project;
  }

  @override
  Future<List<Project>> getAllProjects() async =>
      UnmodifiableListView(_storage.values).toList();

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
}
