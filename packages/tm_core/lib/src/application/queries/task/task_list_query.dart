import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/task_repository.dart';

class TaskListParams {
  const TaskListParams({
    required this.projectId,
    this.contextState,
    this.parentId,
    this.status,
    this.stalled = false,
  });

  /// Raw project ID string.
  final String projectId;

  /// Filter by context state: 'active' | 'backlog' | 'in_review' | 'archived'.
  /// Null means all context states.
  final String? contextState;

  /// Filter by parent task UUID. Null means all levels.
  final String? parentId;

  /// Filter by task status string (e.g. 'pending', 'in_progress').
  /// Null means all statuses.
  final String? status;

  /// If true, only return tasks with staleness > 1.0.
  final bool stalled;
}

/// Returns a filtered list of tasks for a project.
///
/// Supports filters from §11.3 (task_list):
/// - `contextState` — optional context filter
/// - `parentId`     — optional parent filter
/// - `status`       — optional status filter
/// - `stalled`      — staleness > 1.0 filter
class TaskListQuery {
  TaskListQuery(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> execute(TaskListParams params) async {
    late final ProjectId projectId;
    try {
      projectId = ProjectId(params.projectId);
    } on FormatException {
      return const [];
    }

    var tasks = await _taskRepository.getByProjectId(projectId);

    // Filter by contextState
    if (params.contextState != null) {
      final ctx = TaskContextState.values
          .where((e) => e.value == params.contextState)
          .firstOrNull;
      if (ctx == null) {
        return const [];
      }
      tasks = tasks.where((t) => t.contextState == ctx).toList();
    }

    // Filter by parentId
    if (params.parentId != null) {
      try {
        final parentId = TaskId(params.parentId!);
        tasks = tasks.where((t) => t.parentId == parentId).toList();
      } on FormatException {
        return const [];
      }
    }

    // Filter by status
    if (params.status != null) {
      final status = TaskStatus.values
          .where((e) => e.value == params.status)
          .firstOrNull;
      if (status == null) {
        return const [];
      }
      tasks = tasks.where((t) => t.status == status).toList();
    }

    // Filter by stalled
    if (params.stalled) {
      final now = DateTime.now().toUtc();
      tasks = tasks.where((t) => calculateStaleness(t, now) > 1.0).toList();
    }

    return tasks;
  }
}
