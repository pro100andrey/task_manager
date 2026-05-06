import '../../domain/entities/task_history.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../../domain/value_objects/task_history/task_history_id.dart';

abstract class TaskHistoryRepository {
  /// Returns a single history entry by its ID, or null if not found.
  Future<TaskHistory?> getById(TaskHistoryId id);

  /// Returns all history entries for a task, ordered by changedAt ascending.
  Future<List<TaskHistory>> getByTaskId(TaskId taskId);

  /// Persists a history entry (insert only — history is append-only).
  Future<TaskHistory> save(TaskHistory entry);
}
