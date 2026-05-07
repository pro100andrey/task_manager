import '../../../domain/entities/knowledge_entity.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_knowledge_ref.dart';
import '../../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../ports/knowledge_repository.dart';
import '../../ports/task_knowledge_ref_repository.dart';
import '../../ports/task_repository.dart';

class KnowledgeEntityDetails {
  const KnowledgeEntityDetails({
    required this.entity,
    required this.refs,
    required this.tasks,
  });

  final KnowledgeEntity entity;
  final List<TaskKnowledgeRef> refs;
  final List<Task> tasks;
}

class GetKnowledgeEntityQuery {
  GetKnowledgeEntityQuery(
    this._knowledgeRepository,
    this._taskKnowledgeRefRepository,
    this._taskRepository,
  );

  final KnowledgeRepository _knowledgeRepository;
  final TaskKnowledgeRefRepository _taskKnowledgeRefRepository;
  final TaskRepository _taskRepository;

  Future<KnowledgeEntityDetails?> execute(KnowledgeEntityId entityId) async {
    if (entityId.formatError case final _?) {
      return null;
    }

    final entity = await _knowledgeRepository.getById(entityId);
    if (entity == null) {
      return null;
    }

    final refs = await _taskKnowledgeRefRepository.getByEntityId(entityId);
    final projectTasks = await _taskRepository.getByProjectId(entity.projectId);
    final taskById = {for (final t in projectTasks) t.id: t};

    final tasks = <Task>[];
    for (final ref in refs) {
      final task = taskById[ref.taskId];
      if (task != null) {
        tasks.add(task);
      }
    }

    return KnowledgeEntityDetails(entity: entity, refs: refs, tasks: tasks);
  }
}
