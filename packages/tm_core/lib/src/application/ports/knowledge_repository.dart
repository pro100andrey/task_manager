import '../../domain/entities/knowledge_entity.dart';
import '../../domain/enums/knowledge_entity_type.dart';
import '../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../domain/value_objects/project/project_id.dart';

abstract class KnowledgeRepository {
  Future<KnowledgeEntity?> getById(KnowledgeEntityId id);
  Future<KnowledgeEntity?> getByName(
    ProjectId projectId,
    String normalizedName,
  );
  Future<List<KnowledgeEntity>> getByProjectId(ProjectId projectId);
  Future<List<KnowledgeEntity>> getByType(
    ProjectId projectId,
    KnowledgeEntityType type,
  );
  Future<KnowledgeEntity> save(KnowledgeEntity entity);
  Future<void> delete(KnowledgeEntityId id);
}
