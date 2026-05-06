import '../../../domain/entities/knowledge_entity.dart';
import '../../../domain/enums/knowledge_entity_type.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../ports/knowledge_repository.dart';

class GetKnowledgeEntitiesParams {
  const GetKnowledgeEntitiesParams({
    required this.projectId,
    this.entityType,
    this.search,
  });

  final String projectId;
  final String? entityType;
  final String? search;
}

class GetKnowledgeEntitiesQuery {
  GetKnowledgeEntitiesQuery(this._knowledgeRepository);

  final KnowledgeRepository _knowledgeRepository;

  Future<List<KnowledgeEntity>> execute(
    GetKnowledgeEntitiesParams params,
  ) async {
    final projectId = ProjectId(params.projectId);
    if (projectId.formatError != null) {
      return const [];
    }

    List<KnowledgeEntity> list;
    if (params.entityType != null) {
      final type = KnowledgeEntityType.tryParse(params.entityType!);
      if (type == null) {
        return const [];
      }
      list = await _knowledgeRepository.getByType(projectId, type);
    } else {
      list = await _knowledgeRepository.getByProjectId(projectId);
    }

    final search = params.search?.trim().toLowerCase();
    if (search == null || search.isEmpty) {
      return list;
    }

    return list
        .where(
          (e) =>
              e.name.toLowerCase().contains(search) ||
              e.content.toLowerCase().contains(search),
        )
        .toList();
  }
}
