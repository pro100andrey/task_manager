import '../../../tm_core.dart';

const _actionHistoryKey = 'actionHistory';
const _pnrWindowsKey = 'pnrWindows';

class TaskPnrWindow {
  const TaskPnrWindow({required this.created, required this.completed});

  final int created;
  final int completed;

  Map<String, dynamic> toJson() => {
    'created': created,
    'completed': completed,
  };
}

/// Normalizes a raw alias string according to §6 of the spec.
///
/// Rules applied in order:
/// 1. Trim whitespace
/// 2. toLowerCase
/// 3. Replace spaces and '/' with '-'
/// 4. Remove characters outside [a-z0-9_-]
/// 5. Remove leading and trailing '-'

String normalizeAlias(String raw) {
  var result = raw.trim();
  result = result.toLowerCase();
  result = result.replaceAll(RegExp('[ /]'), '-');
  result = result.replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
  result = result.replaceAll(RegExp(r'^-+|-+$'), '');

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
  final raw = task.metadata[_actionHistoryKey];
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

List<TaskPnrWindow> taskPnrWindows(Task task) {
  final raw = task.metadata[_pnrWindowsKey];
  if (raw is! List) {
    return const [];
  }

  return raw
      .whereType<Map>()
      .map((entry) {
        final created = entry['created'];
        final completed = entry['completed'];
        if (created is int && completed is int) {
          return TaskPnrWindow(created: created, completed: completed);
        }
        return null;
      })
      .nonNulls
      .toList();
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
    _actionHistoryKey: trimmed.map((value) => value.value).toList(),
  };
}

Map<String, dynamic> appendTaskPnrWindow(
  Task task, {
  required int created,
  int completed = 0,
}) {
  final windows = [
    ...taskPnrWindows(task),
    TaskPnrWindow(created: created, completed: completed),
  ];
  final trimmed = windows.length > 10
      ? windows.sublist(windows.length - 10)
      : windows;

  return {
    ...task.metadata,
    _pnrWindowsKey: trimmed.map((window) => window.toJson()).toList(),
  };
}

Map<String, dynamic> incrementTaskPnrCompleted(Task task, {int delta = 1}) {
  final windows = taskPnrWindows(task);
  if (windows.isEmpty) {
    return task.metadata;
  }

  final updated = [...windows];
  final last = updated.removeLast();
  updated.add(
    TaskPnrWindow(
      created: last.created,
      completed: last.completed + delta,
    ),
  );

  return {
    ...task.metadata,
    _pnrWindowsKey: updated.map((window) => window.toJson()).toList(),
  };
}

/// Soft context for a task: tasks linked via soft links.
///
/// - `informs`: tasks with a soft link TO the task (they inform this task).
/// - `informedBy`: tasks with a soft link FROM the task
///   (this task informs them).
/// - `related`: tasks linked with a soft link labelled 'related'
///   (either direction).
class SoftContext {
  const SoftContext({
    required this.informs,
    required this.informedBy,
    required this.related,
  });

  final List<Task> informs;
  final List<Task> informedBy;
  final List<Task> related;
}

/// Staleness score per §5.3: how overdue the task is relative to its effort
/// estimate.
///
/// Returns 0 when `task.estimatedEffort` is null or ≤ 0.
double calculateStaleness(Task task, DateTime now) {
  final effort = task.estimatedEffort;
  if (effort == null || effort <= 0) {
    return 0;
  }
  final elapsed = now.difference(task.lastProgressAt).inSeconds.toDouble();
  return elapsed / (effort * 3600 * 2 + 4 * 3600);
}

/// Unblock score: number of non-completed tasks directly unblocked if
/// `taskId` is completed (strong links from `taskId` to pending tasks).
///
/// `links` — all relevant links; `completedIds` — completed task IDs.
int calculateUnblockScore(
  TaskId taskId,
  List<TaskLink> links,
  Set<TaskId> completedIds,
) => links
    .where(
      (l) =>
          l.linkType == .strong &&
          l.fromTaskId == taskId &&
          !completedIds.contains(l.toTaskId),
    )
    .length;

/// Returns the `SoftContext` for `taskId` based on soft links and `taskMap`.
///
/// Implements §5.7: soft links inform the agent which tasks share context.
SoftContext getSoftContext(
  TaskId taskId,
  List<TaskLink> links,
  Map<TaskId, Task> taskMap,
) {
  final softLinks = links.where((l) => l.linkType == .soft).toList();

  // Tasks whose soft link points TO taskId (they inform this task)
  final informs = softLinks
      .where((l) => l.toTaskId == taskId && l.label != 'related')
      .map((l) => taskMap[l.fromTaskId])
      .nonNulls
      .toList();

  // Tasks that this task's soft link points TO (this task informs them)
  final informedBy = softLinks
      .where((l) => l.fromTaskId == taskId && l.label != 'related')
      .map((l) => taskMap[l.toTaskId])
      .nonNulls
      .toList();

  // Tasks linked with label='related' in either direction
  final related = softLinks
      .where(
        (l) =>
            l.label == 'related' &&
            (l.fromTaskId == taskId || l.toTaskId == taskId),
      )
      .map((l) {
        final otherId = l.fromTaskId == taskId ? l.toTaskId : l.fromTaskId;
        return taskMap[otherId];
      })
      .nonNulls
      .toList();

  return SoftContext(
    informs: informs,
    informedBy: informedBy,
    related: related,
  );
}
