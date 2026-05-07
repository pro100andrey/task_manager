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
  late MemReflectionRepositoryImpl reflectionRepo;
  late MemTaskLinkRepositoryImpl taskLinkRepo;
  late OperationPipeline pipeline;

  late ProjectCreateOperation projectCreate;
  late ProjectSwitchOperation projectSwitch;
  late TaskCreateOperation taskCreate;
  late TaskReflectOperation taskReflect;
  late ReflectionListQuery reflectionList;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    reflectionRepo = MemReflectionRepositoryImpl();
    taskLinkRepo = MemTaskLinkRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl(config: const .new())),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    projectSwitch = ProjectSwitchOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    taskReflect = TaskReflectOperation(
      pipeline,
      projectRepo,
      taskRepo,
      reflectionRepo,
      taskLinkRepo,
      bus,
    );
    reflectionList = ReflectionListQuery(projectRepo, taskRepo, reflectionRepo);

    final created = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Reflection Project')),
    );
    project = (created as Success<Project, dynamic>).value;
    await projectSwitch.execute(ProjectSwitchCommand(projectId: project.id));
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title) async {
    final result = await taskCreate.execute(
      TaskCreateCommand(projectId: project.id, title: title),
    );
    return (result as Success<Task, dynamic>).value;
  }

  test('creates reflection and marks task last action as reflection', () async {
    final task = await createTask('Investigate issue');

    final result = await taskReflect.execute(
      TaskReflectCommand(
        taskId: task.id,
        content: 'Observed recurring timeout.',
      ),
    );

    expect(result.isSuccess, isTrue);
    final value =
        (result as Success<TaskReflectResult, TaskReflectFailure>).value;
    expect(value.reflection.taskId, task.id);
    expect(value.reflection.reflectionType, ReflectionType.observation);
    expect(value.replanTask, isNull);

    final savedTask = await taskRepo.getById(task.id);
    expect(savedTask, isNotNull);
    expect(savedTask!.lastActionType, TaskLastActionType.reflection);
  });

  test('rejects reflection when budget is exhausted', () async {
    final task = await createTask('Investigate issue');

    await taskReflect.execute(
      TaskReflectCommand(
        taskId: task.id,
        content: 'First reflection',
        reflectionBudget: 1,
      ),
    );

    final second = await taskReflect.execute(
      TaskReflectCommand(
        taskId: task.id,
        content: 'Second reflection',
        reflectionBudget: 1,
      ),
    );

    expect(second.isFailure, isTrue);
    expect(
      (second as Failure<TaskReflectResult, TaskReflectFailure>).error,
      isA<TaskReflectBudgetExceeded>(),
    );
  });

  test(
    'creates replan task and soft link when triggerReplan is enabled',
    () async {
      final task = await createTask('Investigate issue');

      final result = await taskReflect.execute(
        TaskReflectCommand(
          taskId: task.id,
          content: 'Need to revise approach.',
          reflectionType: ReflectionType.replanTrigger,
          triggerReplan: true,
        ),
      );

      expect(result.isSuccess, isTrue);
      final value =
          (result as Success<TaskReflectResult, TaskReflectFailure>).value;
      expect(value.replanTask, isNotNull);
      expect(value.replanTask!.title.value, 'Replan based on reflection');

      final links = await taskLinkRepo.getByTaskId(task.id);
      expect(
        links.where((link) => link.toTaskId == value.replanTask!.id),
        isNotEmpty,
      );
    },
  );

  test('uses current project for project-level reflection', () async {
    final result = await taskReflect.execute(
      const TaskReflectCommand(content: 'General observation'),
    );

    expect(result.isSuccess, isTrue);
    final value =
        (result as Success<TaskReflectResult, TaskReflectFailure>).value;
    expect(value.reflection.projectId, project.id);
    expect(value.reflection.taskId, isNull);
  });

  test('reflection_list filters by task, type and since', () async {
    final task = await createTask('Investigate issue');

    await taskReflect.execute(
      TaskReflectCommand(
        taskId: task.id,
        content: 'Old blocker',
        reflectionType: ReflectionType.blocker,
      ),
    );

    final afterFirst = DateTime.now().toUtc().toIso8601String();

    await taskReflect.execute(
      TaskReflectCommand(
        taskId: task.id,
        content: 'Fresh insight',
        reflectionType: ReflectionType.insight,
      ),
    );
    await taskReflect.execute(
      const TaskReflectCommand(
        content: 'Project observation',
      ),
    );

    final list = await reflectionList.execute(
      ReflectionListParams(
        taskId: task.id,
        reflectionType: 'insight',
        since: afterFirst,
      ),
    );

    expect(list, hasLength(1));
    expect(list.single.content, 'Fresh insight');
  });
}
