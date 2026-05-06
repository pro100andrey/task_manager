import '../enums/knowledge_entity_type.dart';
import '../value_objects/knowledge/knowledge_entity_id.dart';
import '../value_objects/project/project_id.dart';

class KnowledgeEntity {
  const KnowledgeEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.normalizedName,
    required this.entityType,
    required this.content,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final KnowledgeEntityId id;
  final ProjectId projectId;
  final String name;
  final String normalizedName;
  final KnowledgeEntityType entityType;
  final String content;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeEntity copyWith({
    String? name,
    String? normalizedName,
    KnowledgeEntityType? entityType,
    String? content,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) => KnowledgeEntity(
    id: id,
    projectId: projectId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    entityType: entityType ?? this.entityType,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
