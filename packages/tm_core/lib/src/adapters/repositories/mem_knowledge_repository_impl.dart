import '../../application/ports/knowledge_repository.dart';
import '../../domain/entities/knowledge_entity.dart';
import '../../domain/enums/knowledge_entity_type.dart';
import '../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../transaction/in_memory_snapshot_store.dart';

class MemKnowledgeRepositoryImpl
    implements KnowledgeRepository, InMemorySnapshotStore {
  final _entitiesById = <String, KnowledgeEntity>{};

  @override
  Future<KnowledgeEntity?> getById(KnowledgeEntityId id) async =>
      _entitiesById[id];

  @override
  Future<KnowledgeEntity?> getByName(
    ProjectId projectId,
    String normalizedName,
  ) async => _entitiesById.values
      .where(
        (e) => e.projectId == projectId && e.normalizedName == normalizedName,
      )
      .firstOrNull;

  @override
  Future<List<KnowledgeEntity>> getByProjectId(ProjectId projectId) async =>
      _entitiesById.values
          .where((e) => e.projectId == projectId)
          .toList(growable: false);

  @override
  Future<List<KnowledgeEntity>> getByType(
    ProjectId projectId,
    KnowledgeEntityType type,
  ) async => _entitiesById.values
      .where((e) => e.projectId == projectId && e.entityType == type)
      .toList(growable: false);

  @override
  Future<KnowledgeEntity> save(KnowledgeEntity entity) async {
    _entitiesById[entity.id] = entity;

    return entity;
  }

  @override
  Future<void> delete(KnowledgeEntityId id) async {
    _entitiesById.remove(id);
  }

  @override
  Object createSnapshot() => Map<String, KnowledgeEntity>.from(_entitiesById);

  @override
  void restoreSnapshot(Object snapshot) {
    final typed = snapshot as Map<String, KnowledgeEntity>;
    _entitiesById
      ..clear()
      ..addAll(typed);
  }
}
