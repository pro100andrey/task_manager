import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_ref.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import 'get_task_by_ref_query.dart';

class TaskGraphParams {
  const TaskGraphParams({
    required this.projectId,
    this.rootRef,
    this.depth,
    this.linkType,
  });

  /// Raw project ID string.
  final ProjectId projectId;

  /// Optional root task reference (UUID v7 or alias). Null = whole project.
  final TaskRef? rootRef;

  /// Maximum depth of the hierarchy tree to include. Null = unlimited.
  final int? depth;

  /// 'strong' | 'soft'. Null = all link types.
  final LinkType? linkType;
}

class TaskGraphNode {
  const TaskGraphNode({
    required this.task,
    required this.ep,
    required this.depth,
  });

  final Task task;

  /// Effective priority with Hard Cap from ancestor chain.
  final double ep;

  /// Depth in the hierarchy tree (0 = root or project-level root).
  final int depth;
}

class TaskGraphResult {
  const TaskGraphResult({required this.nodes, required this.edges});

  /// All tasks included in the graph scope, with ep and depth.
  final List<TaskGraphNode> nodes;

  /// All links between tasks in [nodes], filtered by
  /// [TaskGraphParams.linkType].
  final List<TaskLink> edges;
}

/// Returns the task hierarchy graph for a project per §8.2 / §11.3.
///
/// Optionally rooted at a specific task, with optional depth limit and
/// link_type filter for edges.
class TaskGraphQuery {
  TaskGraphQuery(this._taskRepository, this._linkRepository);

  final TaskRepository _taskRepository;
  final TaskLinkRepository _linkRepository;

  Future<TaskGraphResult?> execute(TaskGraphParams params) async {
    // Validate project ID

    if (params.projectId.formatError case final _?) {
      return null;
    }

    // Optional link-type filter validation
    LinkType? typeFilter;
    if (params.linkType != null) {
      typeFilter = LinkType.values
          .where((e) => e== params.linkType)
          .firstOrNull;
      if (typeFilter == null) {
        return null;
      }
    }

    // Resolve optional root before loading all tasks
    Task? root;
    if (params.rootRef != null) {
      final refQuery = GetTaskByRefQuery(_taskRepository);
      root = await refQuery.execute(
        GetTaskByRefParams(
          projectId: params.projectId,
          ref: params.rootRef!,
        ),
      );
      if (root == null) {
        return null;
      }
    }

    // Load all project tasks
    final allTasks = await _taskRepository.getByProjectId(params.projectId);
    if (allTasks.isEmpty) {
      return const TaskGraphResult(nodes: [], edges: []);
    }

    // Build task map and children map for BFS/DFS
    final taskMap = <TaskId, Task>{for (final t in allTasks) t.id: t};
    final children = <TaskId, List<Task>>{};
    for (final task in allTasks) {
      if (task.parentId != null) {
        children.putIfAbsent(task.parentId!, () => []).add(task);
      }
    }

    // Collect nodes via BFS starting from root (or project roots)
    final nodes = <TaskGraphNode>[];
    final includedIds = <TaskId>{};

    // Compute own EP helper
    double ownEp(Task t) => t.businessValue * 0.85 + t.urgencyScore * 0.15;

    // Queue: (task, parentEp, depthInGraph)
    final queue = <(Task, double?, int)>[];

    if (root != null) {
      // Compute EP of root including its ancestor chain
      final rootEp = await _computeEp(root, taskMap);
      queue.add((root, rootEp, 0));
    } else {
      // Start from all project-level roots (no parent)
      for (final task in allTasks) {
        if (task.parentId == null) {
          queue.add((task, null, 0));
        }
      }
    }

    while (queue.isNotEmpty) {
      final (task, parentEp, d) = queue.removeAt(0);

      if (includedIds.contains(task.id)) {
        continue;
      }
      includedIds.add(task.id);

      final own = ownEp(task);
      final ep = parentEp == null ? own : (own < parentEp ? own : parentEp);
      nodes.add(TaskGraphNode(task: task, ep: ep, depth: d));

      // Recurse into children if depth allows
      if (params.depth == null || d < params.depth!) {
        for (final child in (children[task.id] ?? [])) {
          queue.add((child, ep, d + 1));
        }
      }
    }

    // Load all links for the included task IDs
    final taskIds = includedIds.toList();
    final allLinks = await _linkRepository.getAllByProjectLinks(taskIds);

    // Filter links: both ends must be in scope; apply optional link-type filter
    final edges = allLinks.where((link) {
      if (!includedIds.contains(link.fromTaskId)) {
        return false;
      }
      if (!includedIds.contains(link.toTaskId)) {
        return false;
      }
      if (typeFilter != null && link.linkType != typeFilter) {
        return false;
      }
      return true;
    }).toList();

    return TaskGraphResult(nodes: nodes, edges: edges);
  }

  /// Computes EP with Hard Cap by traversing the ancestor chain of [task].
  Future<double> _computeEp(Task task, Map<TaskId, Task> taskMap) async {
    double ownEp(Task t) => t.businessValue * 0.85 + t.urgencyScore * 0.15;

    final chain = <Task>[task];
    var current = task;
    while (current.parentId != null) {
      final parent = taskMap[current.parentId!];
      if (parent == null) {
        break;
      }
      chain.insert(0, parent);
      current = parent;
    }

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
