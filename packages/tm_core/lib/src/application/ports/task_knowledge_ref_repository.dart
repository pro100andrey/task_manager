import '../../domain/entities/task_knowledge_ref.dart';
import '../../domain/enums/knowledge_ref_type.dart';
import '../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../domain/value_objects/task/task_id.dart';

abstract class TaskKnowledgeRefRepository {
  Future<List<TaskKnowledgeRef>> getByTaskId(TaskId taskId);
  Future<List<TaskKnowledgeRef>> getByEntityId(KnowledgeEntityId entityId);
  Future<TaskKnowledgeRef?> get(
    TaskId taskId,
    KnowledgeEntityId entityId,
    KnowledgeRefType refType,
  );
  Future<TaskKnowledgeRef> save(TaskKnowledgeRef ref);
  Future<void> delete(
    TaskId taskId,
    KnowledgeEntityId entityId,
    KnowledgeRefType? type,
  );
}
