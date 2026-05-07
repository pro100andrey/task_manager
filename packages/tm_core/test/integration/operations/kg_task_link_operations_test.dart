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

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Knowledge Link Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title) async {
    final r = await taskCreate.execute(
      TaskCreateCommand(projectId: project.id, title: title),
    );
    return (r as Success<Task, dynamic>).value;
  }

  Future<KnowledgeEntity> createEntity(String name) async {
    final r = await kgEntityAdd.execute(
      KgEntityAddCommand(
        projectId: project.id,
        name: name,
        entityType: 'fact',
        content: 'knowledge',
      ),
    );
    return (r as Success<KnowledgeEntity, dynamic>).value;
  }

  test('adds task knowledge ref', () async {
    final task = await createTask('Design schema');
    final entity = await createEntity('Schema');

    final result = await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: task.id,
        entityId: entity.id,
        refType: 'produces',
      ),
    );

    expect(result.isSuccess, isTrue);
    final ref = (result as Success<TaskKnowledgeRef, KgTaskLinkFailure>).value;
    expect(ref.taskId, task.id);
    expect(ref.entityId, entity.id);
    expect(ref.refType, KnowledgeRefType.produces);
  });

  test('creates auto bridge soft link for produces + consumes', () async {
    final producer = await createTask('Design schema');
    final consumer = await createTask('Implement auth');
    final entity = await createEntity('Schema');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: producer.id,
        entityId: entity.id,
        refType: 'produces',
      ),
    );
    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: consumer.id,
        entityId: entity.id,
        refType: 'consumes',
      ),
    );

    final soft = await taskLinkRepo.get(
      producer.id,
      consumer.id,
      LinkType.soft,
    );
    expect(soft, isNotNull);
    expect(soft!.label, contains('auto_bridge:'));
  });

  test('auto bridge is idempotent for repeated calls', () async {
    final producer = await createTask('Design schema');
    final consumer = await createTask('Implement auth');
    final entity = await createEntity('Schema');

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: producer.id,
        entityId: entity.id,
        refType: 'produces',
      ),
    );

    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: consumer.id,
        entityId: entity.id,
        refType: 'consumes',
      ),
    );
    await kgTaskLink.execute(
      KgTaskLinkCommand(
        taskId: consumer.id,
        entityId: entity.id,
        refType: 'consumes',
      ),
    );

    final links = await taskLinkRepo.getByTaskId(producer.id);
    final softLinks = links
        .where(
          (l) =>
              l.fromTaskId == producer.id &&
              l.toTaskId == consumer.id &&
              l.linkType == LinkType.soft,
        )
        .toList();
    expect(softLinks, hasLength(1));
  });
}
