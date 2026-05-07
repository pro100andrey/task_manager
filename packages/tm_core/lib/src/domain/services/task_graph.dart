import '../../../tm_core.dart';

/// Builds an adjacency map from a list of strong links.
///
/// Returns `{ fromId → [toId, ...] }`.
Map<TaskId, List<TaskId>> buildStrongAdjacency(List<TaskLink> links) {
  final adj = <TaskId, List<TaskId>>{};
  for (final link in links) {
    if (link.linkType == .strong) {
      adj.putIfAbsent(link.fromTaskId, () => []).add(link.toTaskId);
    }
  }
  return adj;
}

/// Detects a cycle in the strong-link DAG.
///
/// Throws [CycleException] with the cycle path if one is found.
/// The [extraFrom] and [extraTo] allow testing a hypothetical new edge
/// before it is persisted.
void detectCycle(
  Map<TaskId, List<TaskId>> adj, {
  TaskId? extraFrom,
  TaskId? extraTo,
}) {
  // Build a working copy with the hypothetical edge if provided.
  final graph = <TaskId, List<TaskId>>{
    for (final e in adj.entries) e.key: List<TaskId>.from(e.value),
  };
  if (extraFrom != null && extraTo != null) {
    graph.putIfAbsent(extraFrom, () => []).add(extraTo);
  }

  // DFS with path tracking.
  final visited = <TaskId>{};
  final inStack = <TaskId>{};
  final path = <TaskId>[];

  void dfs(TaskId node) {
    if (inStack.contains(node)) {
      // Found cycle — extract the cycle portion of the path.
      final start = path.indexOf(node);
      throw CycleException([...path.sublist(start), node]);
    }
    if (visited.contains(node)) {
      return;
    }

    visited.add(node);
    inStack.add(node);
    path.add(node);

    (graph[node] ?? []).forEach(dfs);

    path.removeLast();
    inStack.remove(node);
  }

  final allNodes = {
    ...graph.keys,
    for (final vs in graph.values) ...vs,
  };
  for (final node in allNodes) {
    if (!visited.contains(node)) {
      dfs(node);
    }
  }
}

/// Returns a topological ordering of all nodes reachable in [adj].
///
/// Throws [CycleException] if a cycle is detected (should not happen if
/// [detectCycle] was called first, but guards against concurrent mutations).
List<TaskId> topologicalSort(Map<TaskId, List<TaskId>> adj) {
  final allNodes = <TaskId>{
    ...adj.keys,
    for (final vs in adj.values) ...vs,
  };

  final visited = <TaskId>{};
  final result = <TaskId>[];

  final inStack = <TaskId>{};
  final path = <TaskId>[];

  void visit(TaskId node) {
    if (inStack.contains(node)) {
      final start = path.indexOf(node);
      throw CycleException([...path.sublist(start), node]);
    }
    if (visited.contains(node)) {
      return;
    }

    inStack.add(node);
    path.add(node);

    (adj[node] ?? []).forEach(visit);

    path.removeLast();
    inStack.remove(node);
    visited.add(node);
    result.add(node);
  }

  allNodes.forEach(visit);

  return result.reversed.toList();
}

/// Returns task IDs that are ready to work on:
/// - status is not completed
/// - all strong predecessors are completed
///
/// [completedIds] — set of already-completed task IDs.
/// [allTaskIds]   — all task IDs in scope.
///
/// Throws [CycleException] if the strong graph has a cycle.
List<TaskId> findReadyTasks(
  Map<TaskId, List<TaskId>> strongAdj,
  Set<TaskId> completedIds,
  Set<TaskId> allTaskIds,
) {
  detectCycle(strongAdj);

  // Build reverse map: toId → [fromIds] (predecessors)
  final predecessors = <TaskId, Set<TaskId>>{};
  for (final MapEntry(:key, :value) in strongAdj.entries) {
    for (final to in value) {
      predecessors.putIfAbsent(to, () => {}).add(key);
    }
  }

  return [
    for (final id in allTaskIds)
      if (!completedIds.contains(id))
        if ((predecessors[id] ?? {}).every(completedIds.contains)) id,
  ];
}
