import '../../application/ports/task_link_repository.dart';
import '../../domain/entities/task_link.dart';
import '../../domain/enums/link_type.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemTaskLinkRepositoryImpl
    implements TaskLinkRepository, InMemorySnapshotStore {
  // Composite key: '${from}:${to}:${type}'
  final _links = <String, TaskLink>{};

  static String _key(TaskId from, TaskId to, LinkType type) =>
      '$from:$to:${type.value}';

  @override
  Future<List<TaskLink>> getByTaskId(TaskId taskId) async => _links.values
      .where((l) => l.fromTaskId == taskId || l.toTaskId == taskId)
      .toList();

  @override
  Future<List<TaskLink>> getAllByProjectLinks(
    List<TaskId> projectTaskIds,
  ) async {
    final ids = projectTaskIds.map((t) => t).toSet();
    return _links.values
        .where(
          (l) => ids.contains(l.fromTaskId) && ids.contains(l.toTaskId),
        )
        .toList();
  }

  @override
  Future<TaskLink?> get(TaskId from, TaskId to, LinkType type) async =>
      _links[_key(from, to, type)];

  @override
  Future<TaskLink> save(TaskLink link) async {
    _links[_key(link.fromTaskId, link.toTaskId, link.linkType)] = link;

    return link;
  }

  @override
  Future<void> delete(TaskId from, TaskId to, LinkType? type) async {
    if (type != null) {
      _links.remove(_key(from, to, type));
    } else {
      for (final lt in LinkType.values) {
        _links.remove(_key(from, to, lt));
      }
    }
  }

  @override
  Object createSnapshot() => Map<String, TaskLink>.from(_links);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, TaskLink>;
    _links
      ..clear()
      ..addAll(typed);
  }
}
