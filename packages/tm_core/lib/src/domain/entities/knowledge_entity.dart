import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/knowledge_entity_type.dart';
import '../value_objects/value_objects.dart';

part 'knowledge_entity.freezed.dart';

@freezed
abstract class KnowledgeEntity with _$KnowledgeEntity {
  const factory KnowledgeEntity({
    required KnowledgeEntityId id,
    required ProjectId projectId,
    required String name,
    required String normalizedName,
    required KnowledgeEntityType entityType,
    required String content,
    required Map<String, dynamic> metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KnowledgeEntity;
}
