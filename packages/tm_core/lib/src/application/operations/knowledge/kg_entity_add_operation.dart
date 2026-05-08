import '../../../domain/entities/knowledge_entity.dart';
import '../../../domain/enums/knowledge_entity_type.dart';
import '../../../domain/result.dart';
import '../../../domain/services/knowledge_domain_services.dart';
import '../../ports/knowledge_repository.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/kg_entity_add_command.dart';
import 'failures/kg_entity_add_failure.dart';

typedef _Operation =
    Operation<KgEntityAddCommand, KnowledgeEntity, KgEntityAddFailure>;

class KgEntityAddOperation extends _Operation {
  KgEntityAddOperation(
    super.pipeline,
    this._projectRepository,
    this._knowledgeRepository,
  );

  final ProjectRepository _projectRepository;
  final KnowledgeRepository _knowledgeRepository;

  @override
  String get operationName => 'KgEntityAddOperation';

  @override
  Map<String, dynamic> traceAttributes(KgEntityAddCommand command) => {
    'projectId': command.projectId,
    'name': command.name,
    'entityType': command.entityType,
  };

  @override
  PolicySet<KgEntityAddCommand, KgEntityAddFailure>
  preconditionPolicies(
    KgEntityAddCommand command,
    OperationContext context,
  ) => const PolicySet([]);

  @override
  Future<Result<KnowledgeEntity, KgEntityAddFailure>> run(
    KgEntityAddCommand command,
  ) async {
    if (command.projectId.formatError != null) {
      return Failure(KgEntityAddProjectNotFound(command.projectId));
    }

    final project = await _projectRepository.getById(command.projectId);
    if (project == null) {
      return Failure(KgEntityAddProjectNotFound(command.projectId));
    }

    final entityType = KnowledgeEntityType.tryParse(command.entityType);
    if (entityType == null) {
      return Failure(KgEntityAddInvalidEntityType(command.entityType));
    }

    if (command.content.trim().isEmpty) {
      return const Failure(
        KgEntityAddInvalidContent('content cannot be empty'),
      );
    }

    late final String normalizedName;
    try {
      normalizedName = normalizeKnowledgeName(command.name);
    } on FormatException catch (e) {
      return Failure(KgEntityAddInvalidName(e.message));
    }

    final existing = await _knowledgeRepository.getByName(
      command.projectId,
      normalizedName,
    );
    if (existing != null) {
      return Failure(KgEntityAddNameAlreadyExists(normalizedName));
    }

    final now = DateTime.now().toUtc();

    final entity = KnowledgeEntity(
      id: .generate(),
      projectId: command.projectId,
      name: command.name,
      normalizedName: normalizedName,
      entityType: entityType,
      content: command.content,
      metadata: command.metadata,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _knowledgeRepository.save(entity);
    return Success(saved);
  }
}
