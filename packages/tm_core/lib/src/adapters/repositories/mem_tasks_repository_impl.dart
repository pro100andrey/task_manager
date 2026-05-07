import '../../application/ports/task_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/exceptions/task_exceptions.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/task/task_alias.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemTasksRepositoryImpl implements TaskRepository, InMemorySnapshotStore {
  final _tasks = <TaskId, Task>{};

  @override
  Future<Task?> getById(TaskId id) async => _tasks[id];

  @override
  Future<List<Task>> getByProjectId(ProjectId projectId) async =>
      _tasks.values.where((t) => t.projectId == projectId).toList();

  @override
  Future<Task> save(Task task) async {
    _tasks[task.id] = task;
    return task;
  }

  @override
  Future<void> delete(TaskId id) async {
    if (!_tasks.containsKey(id)) {
      throw TaskNotFoundException(id);
    }
    // Simulate ON DELETE CASCADE: remove all descendants first.
    final children = _tasks.values
        .where((t) => t.parentId == id)
        .map((t) => t.id)
        .toList();
    for (final childId in children) {
      await delete(childId);
    }
    _tasks.remove(id);
  }

  @override
  Future<Task?> getByAlias(
    ProjectId projectId,
    TaskAlias alias,
  ) async => _tasks.values
      .where(
        (t) => t.projectId == projectId && t.alias == alias,
      )
      .firstOrNull;

  @override
  Object createSnapshot() => Map<TaskId, Task>.from(_tasks);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<TaskId, Task>;
    _tasks
      ..clear()
      ..addAll(typed);
  }
}
