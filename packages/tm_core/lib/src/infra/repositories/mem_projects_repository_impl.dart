import 'package:collection/collection.dart';

import '../../application/repositories/project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/project/project_ref.dart';

final class MemProjectsRepositoryImpl implements ProjectRepository {
  final _storage = <ProjectId, Project>{};

  @override
  Future<Project?> getByRef(ProjectRef ref) async {
    if (ref case ProjectRef(isId: true)) {
      return _storage[ref.id];
    } else if (ref case ProjectRef(isName: true)) {
      final project = _storage.values.firstWhereOrNull(
        (p) => p.name == ref.name,
      );

      return project;
    }

    return _storage[ref.id];
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
  Future<Project?> getCurrentProject() {
    throw UnimplementedError();
  }

  @override
  Future<Project> switchCurrentProject(ProjectId id) {
    throw UnimplementedError();
  }
}
