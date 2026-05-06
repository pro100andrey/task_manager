import '../../application/ports/task_history_repository.dart';
import '../../domain/entities/task_history.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../../domain/value_objects/task_history/task_history_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemTaskHistoryRepositoryImpl
    implements TaskHistoryRepository, InMemorySnapshotStore {
  final _entriesById = <String, TaskHistory>{};

  @override
  Future<TaskHistory?> getById(TaskHistoryId id) async => _entriesById[id.raw];

  @override
  Future<List<TaskHistory>> getByTaskId(TaskId taskId) async {
    final result = _entriesById.values.where((e) => e.taskId == taskId).toList()
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));
    return result;
  }

  @override
  Future<TaskHistory> save(TaskHistory entry) async {
    _entriesById[entry.id.raw] = entry;
    return entry;
  }

  @override
  Object createSnapshot() => Map<String, TaskHistory>.from(_entriesById);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, TaskHistory>;
    _entriesById
      ..clear()
      ..addAll(typed);
  }
}
