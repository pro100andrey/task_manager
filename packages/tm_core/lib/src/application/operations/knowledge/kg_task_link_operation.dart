import 'package:uuid/uuid.dart';

import '../../../domain/entities/task_knowledge_ref.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/knowledge_ref_type.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/knowledge_repository.dart';
import '../../ports/task_knowledge_ref_repository.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/kg_task_link_command.dart';
import 'failures/kg_task_link_failure.dart';

typedef _Operation =
    Operation<KgTaskLinkCommand, TaskKnowledgeRef, KgTaskLinkFailure>;

class KgTaskLinkOperation extends _Operation {
  KgTaskLinkOperation(
    super.pipeline,
    this._taskRepository,
    this._knowledgeRepository,
    this._taskKnowledgeRefRepository,
    this._taskLinkRepository,
  );

  final TaskRepository _taskRepository;
  final KnowledgeRepository _knowledgeRepository;
  final TaskKnowledgeRefRepository _taskKnowledgeRefRepository;
  final TaskLinkRepository _taskLinkRepository;

  @override
  String get operationName => 'KgTaskLinkOperation';

  @override
  Map<String, dynamic> traceAttributes(KgTaskLinkCommand command) => {
    'taskId': command.taskId,
    'entityId': command.entityId,
    'refType': command.refType,
  };

  @override
  OperationPolicySet<KgTaskLinkCommand, KgTaskLinkFailure> preconditionPolicies(
    KgTaskLinkCommand command,
    OperationContext context,
  ) => const OperationPolicySet([]);

  @override
  Future<Result<TaskKnowledgeRef, KgTaskLinkFailure>> run(
    KgTaskLinkCommand command,
  ) async {
    late final TaskId taskId;
    late final KnowledgeEntityId entityId;
    try {
      taskId = TaskId(command.taskId);
    } on FormatException {
      return Failure(KgTaskLinkTaskNotFound(command.taskId));
    }

    try {
      entityId = KnowledgeEntityId(command.entityId);
    } on FormatException {
      return Failure(KgTaskLinkEntityNotFound(command.entityId));
    }

    final refType = KnowledgeRefType.tryParse(command.refType);
    if (refType == null) {
      return Failure(KgTaskLinkInvalidRefType(command.refType));
    }

    final task = await _taskRepository.getById(taskId);
    if (task == null) {
      return Failure(KgTaskLinkTaskNotFound(command.taskId));
    }

    final entity = await _knowledgeRepository.getById(entityId);
    if (entity == null) {
      return Failure(KgTaskLinkEntityNotFound(command.entityId));
    }

    if (task.projectId != entity.projectId) {
      return Failure(
        KgTaskLinkCrossProject(
          taskId: command.taskId,
          entityId: command.entityId,
        ),
      );
    }

    final existing = await _taskKnowledgeRefRepository.get(
      taskId,
      entityId,
      refType,
    );
    if (existing != null) {
      return Success(existing);
    }

    final saved = await _taskKnowledgeRefRepository.save(
      TaskKnowledgeRef(
        taskId: taskId,
        entityId: entityId,
        refType: refType,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    await _runAutoBridge(saved);

    return Success(saved);
  }

  Future<void> _runAutoBridge(TaskKnowledgeRef ref) async {
    final refs = await _taskKnowledgeRefRepository.getByEntityId(ref.entityId);

    if (ref.refType.isProduces) {
      final consumers = refs.where((r) => r.refType.isConsumes);
      for (final consumer in consumers) {
        await _ensureSoftLink(
          from: ref.taskId,
          to: consumer.taskId,
          entityId: ref.entityId.raw,
        );
      }
      return;
    }

    if (ref.refType.isConsumes) {
      final producers = refs.where((r) => r.refType.isProduces);
      for (final producer in producers) {
        await _ensureSoftLink(
          from: producer.taskId,
          to: ref.taskId,
          entityId: ref.entityId.raw,
        );
      }
    }
  }

  Future<void> _ensureSoftLink({
    required TaskId from,
    required TaskId to,
    required String entityId,
  }) async {
    if (from == to) {
      return;
    }

    final existing = await _taskLinkRepository.get(from, to, LinkType.soft);
    if (existing != null) {
      return;
    }

    await _taskLinkRepository.save(
      TaskLink(
        id: const Uuid().v7(),
        fromTaskId: from,
        toTaskId: to,
        linkType: LinkType.soft,
        createdAt: DateTime.now().toUtc(),
        label: 'auto_bridge:$entityId',
      ),
    );
  }
}
