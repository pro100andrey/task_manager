import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_completion_policy.dart';
import '../../../domain/value_objects/task/task_id.dart';

class ActiveFrontItem {
  const ActiveFrontItem({
    required this.task,
    required this.ep,
    required this.depth,
    required this.staleness,
    required this.unblockScore,
  });

  /// The task ready to work on.
  final Task task;

  /// Effective priority (with Hard Cap from ancestor chain).
  final double ep;

  /// Depth in the task hierarchy (root = 0).
  final int depth;

  /// Staleness score: how overdue the task is relative to its effort estimate.
  final double staleness;

  /// Number of pending tasks directly unblocked if this task completes.
  final int unblockScore;

  /// Whether the task is stalled (in `front` but staleness > 1.0).
  bool get isStalled => staleness > 1.0;
}

class WaitingChild {
  const WaitingChild({
    required this.task,
    required this.policy,
    required this.remaining,
  });

  /// Parent task waiting for children to satisfy its completion policy.
  final Task task;

  /// The policy that determines when this task can be completed.
  final TaskCompletionPolicy policy;

  /// Number of children still needed to satisfy the policy.
  final int remaining;
}

class BlockedByStrong {
  const BlockedByStrong({required this.task, required this.unmetDeps});

  /// Task that cannot start because prerequisites are not yet completed.
  final Task task;

  /// IDs of the incomplete prerequisite tasks.
  final List<TaskId> unmetDeps;
}

class ActiveFrontResult {
  const ActiveFrontResult({
    required this.front,
    required this.waitingChildren,
    required this.blockedByStrong,
    required this.stalledTasks,
  });

  /// Tasks ready to work on, sorted by priority.
  final List<ActiveFrontItem> front;

  /// Parent tasks waiting for children to complete (not directly workable).
  final List<WaitingChild> waitingChildren;

  /// Pending tasks with unmet strong prerequisites.
  final List<BlockedByStrong> blockedByStrong;

  /// Tasks from `front` with staleness > 1.0.
  final List<ActiveFrontItem> stalledTasks;
}

class GetActiveFrontParams {
  const GetActiveFrontParams({
    required this.projectId,
    this.contextFilter = 'active',
    this.limit = 10,
    this.includeStalled = false,
  });

  final String projectId;

  /// 'active' → contextState in {active, in_review}
  /// 'all'    → contextState in {active, in_review, backlog}
  final String contextFilter;

  /// Maximum items in [ActiveFrontResult.front]. 0 = no limit.
  final int limit;

  /// When true, backlog tasks with staleness > 1.0 are included in `front`.
  final bool includeStalled;
}
