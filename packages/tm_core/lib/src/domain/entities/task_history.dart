import '../enums/reflection_source.dart';
import '../value_objects/task/task_id.dart';
import '../value_objects/task_history/task_history_id.dart';

/// A single audit-trail record for a task field change (§3.9).
///
/// `oldValue` and `newValue` are JSON-encoded strings (or null when
/// the field was not previously set / is being cleared).
class TaskHistory {
  const TaskHistory({
    required this.id,
    required this.taskId,
    required this.fieldChanged,
    required this.changedAt,
    required this.source,
    this.oldValue,
    this.newValue,
  });

  final TaskHistoryId id;

  /// The task this record belongs to.
  final TaskId taskId;

  /// Name of the field that was changed (e.g. `'status'`, `'title'`).
  final String fieldChanged;

  /// JSON-encoded old value, or null if the field had no previous value.
  final String? oldValue;

  /// JSON-encoded new value, or null if the field was cleared.
  final String? newValue;

  final DateTime changedAt;

  /// The interface that triggered the change: cli | tui | mcp.
  final ReflectionSource source;
}
