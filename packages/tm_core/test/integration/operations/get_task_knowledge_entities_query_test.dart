import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_tasks_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/tm_core.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late MemTaskLinkRepositoryImpl taskLinkRepo;
  late MemKnowledgeRepositoryImpl knowledgeRepo;
  late MemTaskKnowledgeRefRepositoryImpl taskKnowledgeRefRepo;
  late OperationPipeline pipeline;

  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late KgEntityAddOperation kgEntityAdd;
  late KgTaskLinkOperation kgTaskLink;
  late GetTaskKnowledgeEntitiesQuery getTaskKnowledgeEntitiesQuery;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    taskLinkRepo = MemTaskLinkRepositoryImpl();
    knowledgeRepo = MemKnowledgeRepositoryImpl();
    taskKnowledgeRefRepo = MemTaskKnowledgeRefRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl(config: const .new())),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    kgEntityAdd = KgEntityAddOperation(pipeline, projectRepo, knowledgeRepo);
    kgTaskLink = KgTaskLinkOperation(
      pipeline,
      taskRepo,
      knowledgeRepo,
      taskKnowledgeRefRepo,
      taskLinkRepo,
    );
    getTaskKnowledgeEntitiesQuery = GetTaskKnowledgeEntitiesQuery(
      taskKnowledgeRefRepo,
      knowledgeRepo,
    );

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Task Knowledge Query Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title) async {
    final result = await taskCreate.execute(
      TaskCreateCommand(projectId: project.id, title: title),
    );
    return (result as Success<Task, dynamic>).value;
  }

  Future<KnowledgeEntity> createEntity(String name, String type) async {
    final result = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id,
        name: name,
        entityType: type,
        content: 'knowledge',
      ),
    );
    return (result as Success<KnowledgeEntity, dynamic>).value;
  }

  test('returns task entities and groups them by ref type', () async {
    final task = await createTask('Implement auth');
    final schema = await createEntity('Schema', 'fact');
    final jwtDecision = await createEntity('JWT Decision', 'decision');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: task.id,
        entityId: schema.id,
        refType: 'consumes',
      ),
    );
    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: task.id,
        entityId: jwtDecision.id,
        refType: 'updates',
      ),
    );

    final result = await getTaskKnowledgeEntitiesQuery.execute(task.id);

    expect(result.refs, hasLength(2));
    expect(result.entities, hasLength(2));
    expect(result.byType(KnowledgeRefType.consumes), hasLength(1));
    expect(result.byType(KnowledgeRefType.consumes).single.id, schema.id);
    expect(result.byType(KnowledgeRefType.updates), hasLength(1));
    expect(result.byType(KnowledgeRefType.updates).single.id, jwtDecision.id);
  });

  test('returns empty result for invalid task id', () async {
    final result = await getTaskKnowledgeEntitiesQuery.execute('bad-id');
    expect(result.refs, isEmpty);
    expect(result.entities, isEmpty);
  });

  test('returns empty result when task has no knowledge refs', () async {
    final task = await createTask('Lonely task');

    final result = await getTaskKnowledgeEntitiesQuery.execute(task.id);

    expect(result.refs, isEmpty);
    expect(result.entities, isEmpty);
  });

  test('filters out refs whose entities are missing from repository', () async {
    final task = await createTask('Implement auth');
    final entity = await createEntity('Schema', 'fact');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: task.id,
        entityId: entity.id,
        refType: 'consumes',
      ),
    );
    await knowledgeRepo.delete(entity.id);

    final result = await getTaskKnowledgeEntitiesQuery.execute(task.id);

    expect(result.refs, hasLength(1));
    expect(result.entities, isEmpty);
  });
}
