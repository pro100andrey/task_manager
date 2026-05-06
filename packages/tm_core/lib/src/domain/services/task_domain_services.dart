import '../entities/task.dart';
import '../enums/task_completion_policy.dart';
import '../enums/task_last_action_type.dart';
import '../exceptions/task_exceptions.dart';

/// Normalizes a raw alias string according to §6 of the spec.
///
/// Rules applied in order:
/// 1. Trim whitespace
/// 2. toLowerCase
/// 3. Replace spaces and '/' with '-'
/// 4. Remove characters outside [a-z0-9_-]
/// 5. Remove leading and trailing '-'
/// 6. If empty after normalization → throws [InvalidAliasException]
String normalizeAlias(String raw) {
  var result = raw.trim();
  result = result.toLowerCase();
  result = result.replaceAll(RegExp('[ /]'), '-');
  result = result.replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
  result = result.replaceAll(RegExp(r'^-+|-+$'), '');

  if (result.isEmpty) {
    throw InvalidAliasException(raw, 'normalizes to empty string');
  }

  return result;
}

/// Determines if [task] is completable given the full list of tasks in the
/// project.
///
/// Implements the completion policy logic from §5.5 of the spec.
bool isCompletable(Task task, List<Task> allTasks) {
  final children = allTasks.where((t) => t.parentId == task.id).toList();

  if (children.isEmpty) {
    return true;
  }

  final completedChildren = children
      .where((c) => c.status.isCompleted)
      .toList();

  return switch (task.completionPolicy) {
    TaskCompletionPolicy.allChildren =>
      completedChildren.length == children.length,
    TaskCompletionPolicy.anyChild => completedChildren.isNotEmpty,
    TaskCompletionPolicy.manual => true,
  };
}

List<TaskLastActionType> taskActionHistory(Task task) {
  final raw = task.metadata['actionHistory'];
  if (raw is List) {
    final parsed = raw
        .whereType<String>()
        .map(
          (value) => TaskLastActionType.values
              .where((action) => action.value == value)
              .firstOrNull,
        )
        .nonNulls
        .toList();
    if (parsed.isNotEmpty) {
      return parsed;
    }
  }

  return [task.lastActionType];
}

Map<String, dynamic> appendTaskActionHistory(
  Task task,
  TaskLastActionType action,
) {
  final history = [...taskActionHistory(task), action];
  final trimmed = history.length > 3
      ? history.sublist(history.length - 3)
      : history;

  return {
    ...task.metadata,
    'actionHistory': trimmed.map((value) => value.value).toList(),
  };
}
