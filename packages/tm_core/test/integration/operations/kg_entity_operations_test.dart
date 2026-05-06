import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/tm_core.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemKnowledgeRepositoryImpl knowledgeRepo;
  late OperationPipeline pipeline;
  late ProjectCreateOperation projectCreate;
  late KgEntityAddOperation kgEntityAdd;
  late KgEntityUpdateOperation kgEntityUpdate;
  late GetKnowledgeEntitiesQuery kgEntityList;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    knowledgeRepo = MemKnowledgeRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl(config: const .new())),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    kgEntityAdd = KgEntityAddOperation(pipeline, projectRepo, knowledgeRepo);
    kgEntityUpdate = KgEntityUpdateOperation(pipeline, knowledgeRepo);
    kgEntityList = GetKnowledgeEntitiesQuery(knowledgeRepo);

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Knowledge Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  test('adds entity successfully', () async {
    final result = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'Auth Decision',
        entityType: 'decision',
        content: 'Use JWT.',
      ),
    );

    expect(result.isSuccess, isTrue);
    final entity =
        (result as Success<KnowledgeEntity, KgEntityAddFailure>).value;
    expect(entity.normalizedName, 'auth-decision');
    expect(entity.entityType, KnowledgeEntityType.decision);
  });

  test('rejects duplicate normalized names inside project', () async {
    await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'Auth Decision',
        entityType: 'decision',
        content: 'first',
      ),
    );

    final second = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'auth-decision',
        entityType: 'decision',
        content: 'second',
      ),
    );

    expect(second.isFailure, isTrue);
    expect(
      (second as Failure<KnowledgeEntity, KgEntityAddFailure>).error,
      isA<KgEntityAddNameAlreadyExists>(),
    );
  });

  test('updates entity content and metadata', () async {
    final add = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'Schema',
        entityType: 'fact',
        content: 'v1',
      ),
    );
    final entity = (add as Success<KnowledgeEntity, KgEntityAddFailure>).value;

    final updated = await kgEntityUpdate.execute(
      KgEntityUpdateCommand(
        entityId: entity.id.raw,
        content: 'v2',
        metadata: const {'source': 'ops'},
      ),
    );

    expect(updated.isSuccess, isTrue);
    final saved =
        (updated as Success<KnowledgeEntity, KgEntityUpdateFailure>).value;
    expect(saved.content, 'v2');
    expect(saved.metadata['source'], 'ops');
  });

  test('lists knowledge entities with search', () async {
    await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'JWT Decision',
        entityType: 'decision',
        content: 'jwt selected',
      ),
    );
    await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: 'Postgres Fact',
        entityType: 'fact',
        content: 'postgres selected',
      ),
    );

    final list = await kgEntityList.execute(
      GetKnowledgeEntitiesParams(
        projectId: project.id.value,
        search: 'jwt',
      ),
    );

    expect(list, hasLength(1));
    expect(list.first.name, 'JWT Decision');
  });
}
