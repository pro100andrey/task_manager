import '../enums/knowledge_ref_type.dart';
import '../value_objects/knowledge/knowledge_entity_id.dart';
import '../value_objects/task/task_id.dart';

class TaskKnowledgeRef {
  const TaskKnowledgeRef({
    required this.taskId,
    required this.entityId,
    required this.refType,
    required this.createdAt,
  });

  final TaskId taskId;
  final KnowledgeEntityId entityId;
  final KnowledgeRefType refType;
  final DateTime createdAt;
}
