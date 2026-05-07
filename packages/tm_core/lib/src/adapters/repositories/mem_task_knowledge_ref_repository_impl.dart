import '../../application/ports/task_knowledge_ref_repository.dart';
import '../../domain/entities/task_knowledge_ref.dart';
import '../../domain/enums/knowledge_ref_type.dart';
import '../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../domain/value_objects/task/task_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemTaskKnowledgeRefRepositoryImpl
    implements TaskKnowledgeRefRepository, InMemorySnapshotStore {
  final _refs = <String, TaskKnowledgeRef>{};

  String _key(
    TaskId taskId,
    KnowledgeEntityId entityId,
    KnowledgeRefType type,
  ) => '$taskId:$entityId:${type.value}';

  @override
  Future<List<TaskKnowledgeRef>> getByTaskId(TaskId taskId) async =>
      _refs.values.where((r) => r.taskId == taskId).toList();

  @override
  Future<List<TaskKnowledgeRef>> getByEntityId(
    KnowledgeEntityId entityId,
  ) async => _refs.values.where((r) => r.entityId == entityId).toList();

  @override
  Future<TaskKnowledgeRef?> get(
    TaskId taskId,
    KnowledgeEntityId entityId,
    KnowledgeRefType refType,
  ) async => _refs[_key(taskId, entityId, refType)];

  @override
  Future<TaskKnowledgeRef> save(TaskKnowledgeRef ref) async {
    _refs[_key(ref.taskId, ref.entityId, ref.refType)] = ref;
    return ref;
  }

  @override
  Future<void> delete(
    TaskId taskId,
    KnowledgeEntityId entityId,
    KnowledgeRefType? type,
  ) async {
    if (type != null) {
      _refs.remove(_key(taskId, entityId, type));
      return;
    }

    for (final t in KnowledgeRefType.values) {
      _refs.remove(_key(taskId, entityId, t));
    }
  }

  @override
  Object createSnapshot() => Map<String, TaskKnowledgeRef>.from(_refs);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, TaskKnowledgeRef>;
    _refs
      ..clear()
      ..addAll(typed);
  }
}
