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
  late OperationPipeline pipeline;

  late ProjectCreateOperation projectCreate;
  late ProjectSwitchOperation projectSwitch;
  late TaskCreateOperation taskCreate;

  late GetAllProjectsQuery allProjects;
  late GetCurrentProjectQuery currentProject;
  late ReflectionListQuery reflectionList;

  setUp(() {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    reflectionRepo = MemReflectionRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(
        LoggingTracingPortImpl(config: const TracingLoggingConfig()),
      ),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    projectSwitch = ProjectSwitchOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);

    allProjects = GetAllProjectsQuery(projectRepo);
    currentProject = GetCurrentProjectQuery(projectRepo);
    reflectionList = ReflectionListQuery(
      projectRepo,
      taskRepo,
      reflectionRepo,
    );
  });

  tearDown(() => bus.dispose());

  // ── GetAllProjectsQuery ────────────────────────────────────────────────────

  group('GetAllProjectsQuery', () {
    test('returns empty list when no projects exist', () async {
      final result = await allProjects.execute();
      expect(result, isEmpty);
    });

    test('returns all created projects', () async {
      final r1 = await projectCreate.execute(
        const ProjectCreateCommand(name: .new('Alpha')),
      );
      final r2 = await projectCreate.execute(
        const ProjectCreateCommand(name: .new('Beta')),
      );
      final p1 = (r1 as Success<Project, dynamic>).value;
      final p2 = (r2 as Success<Project, dynamic>).value;

      final result = await allProjects.execute();
      expect(result.map((p) => p.id), containsAll([p1.id, p2.id]));
    });
  });

  // ── GetCurrentProjectQuery ─────────────────────────────────────────────────

  group('GetCurrentProjectQuery', () {
    test('returns null when no current project set', () async {
      final result = await currentProject.execute();
      expect(result, isNull);
    });

    test('returns the project after switch', () async {
      final r = await projectCreate.execute(
        const ProjectCreateCommand(name: .new('My Project')),
      );
      final project = (r as Success<Project, dynamic>).value;
      await projectSwitch.execute(
        ProjectSwitchCommand(projectId: project.id),
      );

      final result = await currentProject.execute();
      expect(result, isNotNull);
      expect(result!.id, equals(project.id));
    });

    test(
      'returns null after switching to a new project then deleting it',
      () async {
        final r = await projectCreate.execute(
          const ProjectCreateCommand(name: .new('Temp')),
        );
        final project = (r as Success<Project, dynamic>).value;
        await projectSwitch.execute(
          ProjectSwitchCommand(projectId: project.id),
        );
        await projectRepo.delete(project.id);

        final result = await currentProject.execute();
        expect(result, isNull);
      },
    );
  });

  // ── ReflectionListQuery ────────────────────────────────────────────────────

  group('ReflectionListQuery', () {
    late Project project;

    setUp(() async {
      final r = await projectCreate.execute(
        const ProjectCreateCommand(name: .new('Reflections Project')),
      );
      project = (r as Success<Project, dynamic>).value;
      await projectSwitch.execute(
        ProjectSwitchCommand(projectId: project.id),
      );
    });

    Reflection makeReflection({
      ReflectionType type = ReflectionType.observation,
      TaskId? taskId,
      DateTime? createdAt,
    }) => Reflection(
      id: ReflectionId.generate(),
      projectId: project.id,
      content: 'Some content',
      reflectionType: type,
      triggeredReplan: false,
      reflectionBudget: 3,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      source: ReflectionSource.cli,
      taskId: taskId,
    );

    test('returns empty list when no reflections exist', () async {
      final result = await reflectionList.execute(
        const ReflectionListParams(),
      );
      expect(result, isEmpty);
    });

    test(
      'returns reflections for current project ordered newest first',
      () async {
        final older = makeReflection(
          createdAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
        );
        final newer = makeReflection();
        await reflectionRepo.save(older);
        await reflectionRepo.save(newer);

        final result = await reflectionList.execute(
          const ReflectionListParams(),
        );
        expect(result, hasLength(2));
        expect(result.first.id, equals(newer.id));
      },
    );

    test('filters by reflectionType', () async {
      final obs = makeReflection();
      final dec = makeReflection(type: ReflectionType.decision);
      await reflectionRepo.save(obs);
      await reflectionRepo.save(dec);

      final result = await reflectionList.execute(
        const ReflectionListParams(reflectionType: 'decision'),
      );
      expect(result, hasLength(1));
      expect(result.first.reflectionType, equals(ReflectionType.decision));
    });

    test('invalid reflectionType returns empty list', () async {
      await reflectionRepo.save(makeReflection());

      final result = await reflectionList.execute(
        const ReflectionListParams(reflectionType: 'not_a_type'),
      );
      expect(result, isEmpty);
    });

    test('filters by since date', () async {
      final old = makeReflection(
        createdAt: DateTime.utc(2024),
      );
      final recent = makeReflection(
        createdAt: DateTime.utc(2025, 6),
      );
      await reflectionRepo.save(old);
      await reflectionRepo.save(recent);

      final result = await reflectionList.execute(
        ReflectionListParams(since: DateTime.utc(2025).toIso8601String()),
      );
      expect(result, hasLength(1));
      expect(result.first.id, equals(recent.id));
    });

    test('filters by taskId returns only reflections for that task', () async {
      final taskResult = await taskCreate.execute(
        TaskCreateCommand(
          projectId: project.id,
          title: 'Task for reflection',
        ),
      );
      final task = (taskResult as Success<Task, dynamic>).value;

      final withTask = makeReflection(taskId: task.id);
      final withoutTask = makeReflection();
      await reflectionRepo.save(withTask);
      await reflectionRepo.save(withoutTask);

      final result = await reflectionList.execute(
        ReflectionListParams(taskId: task.id),
      );
      expect(result, hasLength(1));
      expect(result.first.id, equals(withTask.id));
    });

    test('invalid taskId returns empty list', () async {
      final result = await reflectionList.execute(
        const ReflectionListParams(taskId: .new('not-a-uuid')),
      );
      expect(result, isEmpty);
    });

    test('unknown taskId returns empty list', () async {
      final result = await reflectionList.execute(
        ReflectionListParams(taskId: TaskId.generate()),
      );
      expect(result, isEmpty);
    });
  });
}
