import '../entities/task_link.dart';
import '../exceptions/cycle_exception.dart';

/// Builds an adjacency map from a list of strong links.
///
/// Returns `{ fromId → [toId, ...] }`.
Map<String, List<String>> buildStrongAdjacency(List<TaskLink> links) {
  final adj = <String, List<String>>{};
  for (final link in links) {
    if (link.linkType.isStrong) {
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
  Map<String, List<String>> adj, {
  String? extraFrom,
  String? extraTo,
}) {
  // Build a working copy with the hypothetical edge if provided.
  final graph = <String, List<String>>{
    for (final e in adj.entries) e.key: List<String>.from(e.value),
  };
  if (extraFrom != null && extraTo != null) {
    graph.putIfAbsent(extraFrom, () => []).add(extraTo);
  }

  // DFS with path tracking.
  final visited = <String>{};
  final inStack = <String>{};
  final path = <String>[];

  void dfs(String node) {
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
List<String> topologicalSort(Map<String, List<String>> adj) {
  final allNodes = <String>{
    ...adj.keys,
    for (final vs in adj.values) ...vs,
  };

  final visited = <String>{};
  final result = <String>[];

  final inStack = <String>{};
  final path = <String>[];

  void visit(String node) {
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
List<String> findReadyTasks(
  Map<String, List<String>> strongAdj,
  Set<String> completedIds,
  Set<String> allTaskIds,
) {
  detectCycle(strongAdj);

  // Build reverse map: toId → [fromIds] (predecessors)
  final predecessors = <String, Set<String>>{};
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
