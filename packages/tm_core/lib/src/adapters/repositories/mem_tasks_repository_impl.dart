import '../../application/ports/task_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/exceptions/task_exceptions.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/task/task_alias.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemTasksRepositoryImpl implements TaskRepository, InMemorySnapshotStore {
  final _tasks = <String, Task>{};

  @override
  Future<Task?> getById(TaskId id) async => _tasks[id.raw];

  @override
  Future<List<Task>> getByProjectId(ProjectId projectId) async =>
      _tasks.values.where((t) => t.projectId == projectId).toList();

  @override
  Future<Task> save(Task task) async {
    _tasks[task.id.raw] = task;
    return task;
  }

  @override
  Future<void> delete(TaskId id) async {
    if (!_tasks.containsKey(id.raw)) {
      throw TaskNotFoundException(id.raw);
    }
    _tasks.remove(id.raw);
  }

  @override
  Future<Task?> getByAlias(
    ProjectId projectId,
    TaskAlias normalizedAlias,
  ) async => _tasks.values
      .where(
        (t) =>
            t.projectId == projectId &&
            t.normalizedAlias == normalizedAlias.raw,
      )
      .firstOrNull;

  @override
  Object createSnapshot() => Map<String, Task>.from(_tasks);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, Task>;
    _tasks
      ..clear()
      ..addAll(typed);
  }
}
