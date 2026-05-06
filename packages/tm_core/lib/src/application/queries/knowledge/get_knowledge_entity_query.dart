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

  Future<KnowledgeEntityDetails?> execute(String entityId) async {
    late final KnowledgeEntityId id;
    try {
      id = KnowledgeEntityId(entityId);
    } on FormatException {
      return null;
    }

    final entity = await _knowledgeRepository.getById(id);
    if (entity == null) {
      return null;
    }

    final refs = await _taskKnowledgeRefRepository.getByEntityId(id);
    final projectTasks = await _taskRepository.getByProjectId(entity.projectId);
    final taskById = {for (final t in projectTasks) t.id.raw: t};

    final tasks = <Task>[];
    for (final ref in refs) {
      final task = taskById[ref.taskId.raw];
      if (task != null) {
        tasks.add(task);
      }
    }

    return KnowledgeEntityDetails(entity: entity, refs: refs, tasks: tasks);
  }
}
