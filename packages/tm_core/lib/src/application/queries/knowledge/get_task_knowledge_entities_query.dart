import '../../../domain/entities/knowledge_entity.dart';
import '../../../domain/entities/task_knowledge_ref.dart';
import '../../../domain/enums/knowledge_ref_type.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/knowledge_repository.dart';
import '../../ports/task_knowledge_ref_repository.dart';

class TaskKnowledgeEntitiesResult {
  const TaskKnowledgeEntitiesResult({
    required this.entities,
    required this.refs,
  });

  final List<KnowledgeEntity> entities;
  final List<TaskKnowledgeRef> refs;

  List<KnowledgeEntity> byType(KnowledgeRefType type) {
    final ids = refs
        .where((r) => r.refType == type)
        .map((r) => r.entityId)
        .toSet();

    return entities.where((e) => ids.contains(e.id)).toList(growable: false);
  }
}

class GetTaskKnowledgeEntitiesQuery {
  GetTaskKnowledgeEntitiesQuery(this._refRepository, this._knowledgeRepository);

  final TaskKnowledgeRefRepository _refRepository;
  final KnowledgeRepository _knowledgeRepository;

  Future<TaskKnowledgeEntitiesResult> execute(String taskId) async {
    late final TaskId id;
    try {
      id = TaskId(taskId);
    } on FormatException {
      return const TaskKnowledgeEntitiesResult(entities: [], refs: []);
    }

    final refs = await _refRepository.getByTaskId(id);
    if (refs.isEmpty) {
      return const TaskKnowledgeEntitiesResult(entities: [], refs: []);
    }

    final entities = <KnowledgeEntity>[];
    for (final ref in refs) {
      final entity = await _knowledgeRepository.getById(ref.entityId);
      if (entity != null) {
        entities.add(entity);
      }
    }

    return TaskKnowledgeEntitiesResult(entities: entities, refs: refs);
  }
}
