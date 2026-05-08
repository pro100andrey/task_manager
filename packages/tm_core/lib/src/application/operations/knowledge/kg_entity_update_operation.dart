import '../../../domain/entities/knowledge_entity.dart';
import '../../../domain/enums/knowledge_entity_type.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/knowledge/knowledge_entity_id.dart';
import '../../ports/knowledge_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/kg_entity_update_command.dart';
import 'failures/kg_entity_update_failure.dart';

typedef _Operation =
    Operation<KgEntityUpdateCommand, KnowledgeEntity, KgEntityUpdateFailure>;

class KgEntityUpdateOperation extends _Operation {
  KgEntityUpdateOperation(super.pipeline, this._knowledgeRepository);

  final KnowledgeRepository _knowledgeRepository;

  @override
  String get operationName => 'KgEntityUpdateOperation';

  @override
  Map<String, dynamic> traceAttributes(KgEntityUpdateCommand command) => {
    'entityId': command.entityId,
  };

  @override
  PolicySet<KgEntityUpdateCommand, KgEntityUpdateFailure>
  preconditionPolicies(
    KgEntityUpdateCommand command,
    OperationContext context,
  ) => const PolicySet([]);

  @override
  Future<Result<KnowledgeEntity, KgEntityUpdateFailure>> run(
    KgEntityUpdateCommand command,
  ) async {
    late final KnowledgeEntityId entityId;
    try {
      entityId = KnowledgeEntityId(command.entityId);
    } on FormatException {
      return Failure(KgEntityUpdateNotFound(command.entityId));
    }

    final current = await _knowledgeRepository.getById(entityId);
    if (current == null) {
      return Failure(KgEntityUpdateNotFound(command.entityId));
    }

    if (command.content != null && command.content!.trim().isEmpty) {
      return const Failure(
        KgEntityUpdateInvalidContent('content cannot be empty'),
      );
    }

    KnowledgeEntityType? entityType;
    if (command.entityType != null) {
      entityType = KnowledgeEntityType.tryParse(command.entityType!);
      if (entityType == null) {
        return Failure(KgEntityUpdateInvalidEntityType(command.entityType!));
      }
    }

    var updated = current;

    if (command.content case final content?) {
      updated = updated.copyWith(content: content);
    }

    if (entityType case final type?) {
      updated = updated.copyWith(entityType: type);
    }

    if (command.clearMetadata case true) {
      updated = updated.copyWith(metadata: {});
    } else if (command.metadata case final metadata?) {
      updated = updated.copyWith(metadata: metadata);
    }

    updated = updated.copyWith(updatedAt: DateTime.now().toUtc());

    final saved = await _knowledgeRepository.save(updated);

    return Success(saved);
  }
}
