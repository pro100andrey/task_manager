import '../../application/ports/reflection_repository.dart';
import '../../domain/entities/reflection.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/reflection/reflection_id.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemReflectionRepositoryImpl
    implements ReflectionRepository, InMemorySnapshotStore {
  final _reflectionsById = <String, Reflection>{};

  @override
  Future<Reflection?> getById(ReflectionId id) async =>
      _reflectionsById[id.raw];

  @override
  Future<List<Reflection>> getByTaskId(TaskId taskId) async => _reflectionsById
      .values
      .where((reflection) => reflection.taskId == taskId)
      .toList();

  @override
  Future<List<Reflection>> getByProjectId(ProjectId projectId) async =>
      _reflectionsById.values
          .where((reflection) => reflection.projectId == projectId)
          .toList();

  @override
  Future<Reflection> save(Reflection reflection) async {
    _reflectionsById[reflection.id.raw] = reflection;
    return reflection;
  }

  @override
  Object createSnapshot() => Map<String, Reflection>.from(_reflectionsById);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, Reflection>;
    _reflectionsById
      ..clear()
      ..addAll(typed);
  }
}
