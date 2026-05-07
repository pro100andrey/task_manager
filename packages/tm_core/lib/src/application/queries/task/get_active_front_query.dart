import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_completion_policy.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import 'active_front_result.dart';

class GetActiveFrontQuery {
  GetActiveFrontQuery(this._taskRepo, this._linkRepo);

  final TaskRepository _taskRepo;
  final TaskLinkRepository _linkRepo;

  Future<ActiveFrontResult> execute(GetActiveFrontParams params) async {
    if (params.projectId.formatError case final _?) {
      return const ActiveFrontResult(
        front: [],
        waitingChildren: [],
        blockedByStrong: [],
        stalledTasks: [],
      );
    }

    final tasks = await _taskRepo.getByProjectId(params.projectId);
    if (tasks.isEmpty) {
      return const ActiveFrontResult(
        front: [],
        waitingChildren: [],
        blockedByStrong: [],
        stalledTasks: [],
      );
    }

    final taskIds = tasks.map((t) => t.id).toList();
    final links = await _linkRepo.getAllByProjectLinks(taskIds);

    // Maps used throughout
    final taskMap = <TaskId, Task>{for (final t in tasks) t.id: t};
    final completedIds = <TaskId>{
      for (final t in tasks)
        if (t.status.isCompleted) t.id,
    };

    // Build children map: parentId → [children]
    final childrenMap = <TaskId, List<Task>>{};
    for (final t in tasks) {
      if (t.parentId != null) {
        childrenMap.putIfAbsent(t.parentId!, () => []).add(t);
      }
    }

    // Build prerequisite map: taskId → {prerequisite IDs}
    // Convention: TaskLink(from=A, to=B) means A is a prerequisite of B.
    // So for task B, prerequisites are all `from` values where `to = B`.
    final prerequisites = <TaskId, Set<TaskId>>{};
    for (final link in links) {
      if (!link.linkType.isStrong) {
        continue;
      }
      final prereq = link.fromTaskId;
      final dependent = link.toTaskId;
      prerequisites.putIfAbsent(dependent, () => {}).add(prereq);
    }

    // Compute effective priority with Hard Cap
    final epMap = _computeEffectivePriority(tasks, taskMap);
    final depthMap = _computeDepths(tasks, taskMap);

    // Determine allowed contextStates
    final allowedContexts = _allowedContexts(params.contextFilter);

    final front = <ActiveFrontItem>[];
    final blockedByStrong = <BlockedByStrong>[];
    final waitingChildren = <WaitingChild>[];

    for (final task in tasks) {
      if (task.status != TaskStatus.pending) {
        continue;
      }

      // Strong-predecessor check
      final unmetPrereqs = (prerequisites[task.id] ?? {})
          .where((id) => !completedIds.contains(id))
          .toList();

      if (unmetPrereqs.isNotEmpty) {
        blockedByStrong.add(
          BlockedByStrong(task: task, unmetDeps: unmetPrereqs),
        );
        continue;
      }

      // Context filter
      final inAllowed = allowedContexts.contains(task.contextState);
      final staleness = calculateStaleness(task, DateTime.now());
      final isStalled = staleness > 1.0;
      if (!inAllowed) {
        // Backlog stalled tasks can be included if requested
        if (!(params.includeStalled &&
            isStalled &&
            task.contextState == TaskContextState.backlog)) {
          continue;
        }
      }

      // Waiting-children check
      final children = childrenMap[task.id] ?? [];
      if (children.isNotEmpty &&
          task.completionPolicy != TaskCompletionPolicy.manual) {
        final remaining = _remainingChildren(children, task.completionPolicy);
        if (remaining > 0) {
          waitingChildren.add(
            WaitingChild(
              task: task,
              policy: task.completionPolicy,
              remaining: remaining,
            ),
          );
          continue;
        }
      }

      final ep = epMap[task.id] ?? _ownEp(task);
      final depth = depthMap[task.id] ?? 0;
      final unblockScore = calculateUnblockScore(
        task.id,
        links,
        completedIds,
      );
      final softContext = getSoftContext(task.id, links, taskMap);

      front.add(
        ActiveFrontItem(
          task: task,
          ep: ep,
          depth: depth,
          staleness: staleness,
          unblockScore: unblockScore,
          softContext: softContext,
        ),
      );
    }

    // Sort: ep DESC, unblockScore DESC, staleness DESC, createdAt ASC
    front.sort((a, b) {
      final c1 = b.ep.compareTo(a.ep);
      if (c1 != 0) {
        return c1;
      }
      final c2 = b.unblockScore.compareTo(a.unblockScore);
      if (c2 != 0) {
        return c2;
      }
      final c3 = b.staleness.compareTo(a.staleness);
      if (c3 != 0) {
        return c3;
      }
      return a.task.createdAt.compareTo(b.task.createdAt);
    });

    final limitedFront = params.limit > 0
        ? front.take(params.limit).toList()
        : front;

    final stalledTasks = front.where((i) => i.isStalled).toList();

    return ActiveFrontResult(
      front: limitedFront,
      waitingChildren: waitingChildren,
      blockedByStrong: blockedByStrong,
      stalledTasks: stalledTasks,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _ownEp(Task t) =>
      t.businessValue * 0.85 + t.urgencyScore * 0.15;

  /// Computes effective priority for every task in the project, applying
  /// the Hard Cap: ep(child) = min(ep(parent), ownEp(child)).
  static Map<TaskId, double> _computeEffectivePriority(
    List<Task> tasks,
    Map<TaskId, Task> taskMap,
  ) {
    final ep = <TaskId, double>{};

    double computeEp(TaskId id) {
      if (ep.containsKey(id)) {
        return ep[id]!;
      }
      final task = taskMap[id];
      if (task == null) {
        return 0;
      }
      final own = _ownEp(task);
      if (task.parentId == null) {
        ep[id] = own;
        return own;
      }
      final parentEp = computeEp(task.parentId!);
      final capped = own < parentEp ? own : parentEp;
      ep[id] = capped;
      return capped;
    }

    for (final t in tasks) {
      computeEp(t.id);
    }
    return ep;
  }

  /// Computes depth (root = 0) for every task.
  static Map<TaskId, int> _computeDepths(
    List<Task> tasks,
    Map<TaskId, Task> taskMap,
  ) {
    final depths = <TaskId, int>{};

    int computeDepth(TaskId id) {
      if (depths.containsKey(id)) {
        return depths[id]!;
      }

      final task = taskMap[id];
      if (task == null || task.parentId == null) {
        depths[id] = 0;
        return 0;
      }

      final d = 1 + computeDepth(task.parentId!);
      depths[id] = d;

      return d;
    }

    for (final t in tasks) {
      computeDepth(t.id);
    }
    return depths;
  }

  static Set<TaskContextState> _allowedContexts(String contextFilter) {
    if (contextFilter == 'all') {
      return {
        TaskContextState.active,
        TaskContextState.inReview,
        TaskContextState.backlog,
      };
    }
    return {TaskContextState.active, TaskContextState.inReview};
  }

  static int _remainingChildren(
    List<Task> children,
    TaskCompletionPolicy policy,
  ) {
    final nonTerminal = children.where((c) => !c.status.isTerminal).length;
    switch (policy) {
      case TaskCompletionPolicy.allChildren:
        return nonTerminal;
      case TaskCompletionPolicy.anyChild:
        final completed = children.where((c) => c.status.isCompleted).length;
        return completed > 0 ? 0 : 1;
      case TaskCompletionPolicy.manual:
        return 0;
    }
  }
}
