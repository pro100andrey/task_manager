import '../../../domain/entities/task.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/knowledge_repository.dart';
import '../../ports/task_knowledge_ref_repository.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../knowledge/get_task_knowledge_entities_query.dart';
import 'get_task_by_ref_query.dart';

class TaskShowParams {
  const TaskShowParams({
    required this.projectId,
    required this.ref,
  });

  /// Raw project ID string.
  final String projectId;

  /// Task reference: UUID v7 or alias (§7).
  final String ref;
}

/// Rich view of a single task per §11.3 (task_show).
///
/// Includes: task, ep (with Hard Cap), staleness, softContext,
/// and knowledge entities linked to the task.
class TaskShowResult {
  const TaskShowResult({
    required this.task,
    required this.ep,
    required this.staleness,
    required this.softContext,
    required this.knowledgeEntities,
  });

  final Task task;

  /// Effective priority with Hard Cap from ancestor chain.
  final double ep;

  /// Staleness score per §5.3.
  final double staleness;

  /// Soft-link context per §5.7.
  final SoftContext softContext;

  /// Knowledge entities linked to this task.
  final TaskKnowledgeEntitiesResult knowledgeEntities;
}

/// Returns a rich view of a single task.
class TaskShowQuery {
  TaskShowQuery(
    this._taskRepository,
    this._linkRepository,
    this._knowledgeRefRepository,
    this._knowledgeRepository,
  );

  final TaskRepository _taskRepository;
  final TaskLinkRepository _linkRepository;
  final TaskKnowledgeRefRepository _knowledgeRefRepository;
  final KnowledgeRepository _knowledgeRepository;

  Future<TaskShowResult?> execute(TaskShowParams params) async {
    // Resolve the task ref
    final refQuery = GetTaskByRefQuery(_taskRepository);
    final task = await refQuery.execute(
      GetTaskByRefParams(projectId: params.projectId, ref: params.ref),
    );
    if (task == null) {
      return null;
    }

    // Compute EP with Hard Cap (traverse ancestor chain top-down)
    final ep = await _computeEp(task);

    // Compute staleness
    final staleness = calculateStaleness(task, DateTime.now().toUtc());

    // Soft context: need all project links + task map
    late final ProjectId projectId;
    try {
      projectId = ProjectId(params.projectId);
    } on FormatException {
      return null;
    }
    final allTasks = await _taskRepository.getByProjectId(projectId);
    final taskIds = allTasks.map((t) => TaskId(t.id.raw)).toList();
    final links = await _linkRepository.getAllByProjectLinks(taskIds);
    final taskMap = <String, Task>{for (final t in allTasks) t.id.raw: t};
    final softContext = getSoftContext(task.id.raw, links, taskMap);

    // Knowledge entities
    final knowledgeQuery = GetTaskKnowledgeEntitiesQuery(
      _knowledgeRefRepository,
      _knowledgeRepository,
    );
    final knowledgeEntities = await knowledgeQuery.execute(task.id.raw);

    return TaskShowResult(
      task: task,
      ep: ep,
      staleness: staleness,
      softContext: softContext,
      knowledgeEntities: knowledgeEntities,
    );
  }

  /// Computes EP with Hard Cap by traversing the ancestor chain.
  ///
  /// Builds the chain from root to task, then applies Hard Cap top-down:
  /// `ep(child) = min(ep(parent), ownEp(child))`.
  Future<double> _computeEp(Task task) async {
    double ownEp(Task t) => t.businessValue * 0.85 + t.urgencyScore * 0.15;

    // Collect ancestor chain: walk up to root
    final chain = <Task>[task];
    var current = task;
    while (current.parentId != null) {
      final parent = await _taskRepository.getById(current.parentId!);
      if (parent == null) {
        break;
      }
      chain.insert(0, parent);
      current = parent;
    }

    // Apply Hard Cap top-down
    var ep = ownEp(chain.first);
    for (final t in chain.skip(1)) {
      final own = ownEp(t);
      if (own < ep) {
        ep = own;
      }
    }
    return ep;
  }
}
