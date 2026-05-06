import '../../application/ports/knowledge_repository.dart';
import '../../domain/entities/knowledge_entity.dart';
import '../../domain/enums/knowledge_entity_type.dart';
import '../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../domain/value_objects/project/project_id.dart';

class MemKnowledgeRepositoryImpl implements KnowledgeRepository {
  final _entitiesById = <String, KnowledgeEntity>{};

  @override
  Future<KnowledgeEntity?> getById(KnowledgeEntityId id) async =>
      _entitiesById[id.raw];

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
      _entitiesById.values.where((e) => e.projectId == projectId).toList();

  @override
  Future<List<KnowledgeEntity>> getByType(
    ProjectId projectId,
    KnowledgeEntityType type,
  ) async => _entitiesById.values
      .where((e) => e.projectId == projectId && e.entityType == type)
      .toList();

  @override
  Future<KnowledgeEntity> save(KnowledgeEntity entity) async {
    _entitiesById[entity.id.raw] = entity;
    return entity;
  }

  @override
  Future<void> delete(KnowledgeEntityId id) async {
    _entitiesById.remove(id.raw);
  }
}
