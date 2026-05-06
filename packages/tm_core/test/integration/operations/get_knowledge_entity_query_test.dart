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
  late MemKnowledgeRepositoryImpl knowledgeRepo;
  late MemTaskKnowledgeRefRepositoryImpl taskKnowledgeRefRepo;
  late OperationPipeline pipeline;

  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late KgEntityAddOperation kgEntityAdd;
  late KgTaskLinkOperation kgTaskLink;
  late GetKnowledgeEntityQuery getKnowledgeEntityQuery;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
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
      MemTaskLinkRepositoryImpl(),
    );
    getKnowledgeEntityQuery = GetKnowledgeEntityQuery(
      knowledgeRepo,
      taskKnowledgeRefRepo,
      taskRepo,
    );

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Knowledge Query Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title) async {
    final result = await taskCreate.execute(
      TaskCreateCommand(projectId: project.id.value, title: title),
    );
    return (result as Success<Task, dynamic>).value;
  }

  Future<KnowledgeEntity> createEntity(String name) async {
    final result = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id.value,
        name: name,
        entityType: 'fact',
        content: 'knowledge',
      ),
    );
    return (result as Success<KnowledgeEntity, dynamic>).value;
  }

  test('returns entity details with refs and linked tasks', () async {
    final taskA = await createTask('Design schema');
    final taskB = await createTask('Implement auth');
    final entity = await createEntity('Schema');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: taskA.id.raw,
        entityId: entity.id.raw,
        refType: 'produces',
      ),
    );
    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: taskB.id.raw,
        entityId: entity.id.raw,
        refType: 'consumes',
      ),
    );

    final details = await getKnowledgeEntityQuery.execute(entity.id.raw);

    expect(details, isNotNull);
    expect(details!.entity.id, entity.id);
    expect(details.refs, hasLength(2));
    expect(details.tasks.map((t) => t.id), containsAll([taskA.id, taskB.id]));
  });

  test('returns null for invalid entity id', () async {
    final details = await getKnowledgeEntityQuery.execute('not-a-uuid');
    expect(details, isNull);
  });

  test('returns null for missing entity', () async {
    final details = await getKnowledgeEntityQuery.execute(
      KnowledgeEntityId.generate().raw,
    );
    expect(details, isNull);
  });

  test('filters out refs whose tasks are missing from repository', () async {
    final task = await createTask('Temporary task');
    final entity = await createEntity('Schema');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: task.id.raw,
        entityId: entity.id.raw,
        refType: 'produces',
      ),
    );
    await taskRepo.delete(task.id);

    final details = await getKnowledgeEntityQuery.execute(entity.id.raw);

    expect(details, isNotNull);
    expect(details!.refs, hasLength(1));
    expect(details.tasks, isEmpty);
  });
}
