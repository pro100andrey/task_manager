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
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late MemTaskLinkRepositoryImpl linkRepo;
  late MemKnowledgeRepositoryImpl knowledgeRepo;
  late MemTaskKnowledgeRefRepositoryImpl knowledgeRefRepo;
  late DomainEventBusImpl bus;
  late OperationPipeline pipeline;

  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskRenameAliasOperation renameAlias;
  late TaskLinkAddOperation linkAdd;

  late GetTaskByRefQuery taskResolve;
  late TaskListQuery taskList;
  late LinkListQuery linkList;
  late TaskShowQuery taskShow;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    linkRepo = MemTaskLinkRepositoryImpl();
    knowledgeRepo = MemKnowledgeRepositoryImpl();
    knowledgeRefRepo = MemTaskKnowledgeRefRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(
        LoggingTracingPortImpl(config: const TracingLoggingConfig()),
      ),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    renameAlias = TaskRenameAliasOperation(pipeline, taskRepo, bus);
    linkAdd = TaskLinkAddOperation(pipeline, taskRepo, linkRepo, bus);

    taskResolve = GetTaskByRefQuery(taskRepo);
    taskList = TaskListQuery(taskRepo);
    linkList = LinkListQuery(linkRepo, taskRepo);
    taskShow = TaskShowQuery(
      taskRepo,
      linkRepo,
      knowledgeRefRepo,
      knowledgeRepo,
    );

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Test Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(
    String title, {
    int bv = 50,
    int us = 50,
    String? parentId,
    TaskContextState contextState = TaskContextState.active,
    double? estimatedEffort,
    DateTime? lastProgressAt,
  }) async {
    final r = await taskCreate.execute(
      TaskCreateCommand(
        projectId: project.id.value,
        title: title,
        businessValue: bv,
        urgencyScore: us,
        parentId: parentId,
        contextState: contextState,
        estimatedEffort: estimatedEffort,
      ),
    );
    return (r as Success<Task, dynamic>).value;
  }

  // ── GetTaskByRefQuery ─────────────────────────────────────────────────────

  group('GetTaskByRefQuery (task_resolve)', () {
    test('resolves task by UUID', () async {
      final task = await createTask('My Task');
      final found = await taskResolve.execute(
        GetTaskByRefParams(
          projectId: project.id.value,
          ref: task.id.raw,
        ),
      );
      expect(found, isNotNull);
      expect(found!.id, task.id);
    });

    test('resolves task by alias', () async {
      final task = await createTask('My Task');
      await renameAlias.execute(
        TaskRenameAliasCommand(
          taskId: task.id.raw,
          alias: 'my-task',
        ),
      );
      final found = await taskResolve.execute(
        GetTaskByRefParams(
          projectId: project.id.value,
          ref: 'my-task',
        ),
      );
      expect(found, isNotNull);
      expect(found!.id, task.id);
    });

    test('normalizes alias before lookup', () async {
      final task = await createTask('My Task');
      await renameAlias.execute(
        TaskRenameAliasCommand(
          taskId: task.id.raw,
          alias: 'my-task',
        ),
      );
      final found = await taskResolve.execute(
        GetTaskByRefParams(
          projectId: project.id.value,
          ref: 'MY TASK',
        ),
      );
      expect(found, isNotNull);
      expect(found!.id, task.id);
    });

    test('returns null for unknown UUID', () async {
      final unknown = TaskId.generate();
      final found = await taskResolve.execute(
        GetTaskByRefParams(
          projectId: project.id.value,
          ref: unknown.raw,
        ),
      );
      expect(found, isNull);
    });

    test('returns null for unknown alias', () async {
      final found = await taskResolve.execute(
        GetTaskByRefParams(
          projectId: project.id.value,
          ref: 'no-such-task',
        ),
      );
      expect(found, isNull);
    });

    test('returns null for invalid project ID', () async {
      final found = await taskResolve.execute(
        const GetTaskByRefParams(
          projectId: 'not-a-uuid',
          ref: 'anything',
        ),
      );
      expect(found, isNull);
    });
  });

  // ── TaskListQuery ─────────────────────────────────────────────────────────

  group('TaskListQuery (task_list)', () {
    test('returns all tasks in project', () async {
      await createTask('A');
      await createTask('B');
      final tasks = await taskList.execute(
        TaskListParams(projectId: project.id.value),
      );
      expect(tasks, hasLength(2));
    });

    test('filters by contextState', () async {
      await createTask('Active');
      await createTask('Backlog', contextState: TaskContextState.backlog);
      final tasks = await taskList.execute(
        TaskListParams(
          projectId: project.id.value,
          contextState: 'backlog',
        ),
      );
      expect(tasks, hasLength(1));
      expect(tasks.first.title.value, 'Backlog');
    });

    test('filters by parentId', () async {
      final parent = await createTask('Parent');
      await createTask('Child A', parentId: parent.id.raw);
      await createTask('Child B', parentId: parent.id.raw);
      await createTask('Root');
      final tasks = await taskList.execute(
        TaskListParams(
          projectId: project.id.value,
          parentId: parent.id.raw,
        ),
      );
      expect(tasks, hasLength(2));
      expect(tasks.every((t) => t.parentId == parent.id), isTrue);
    });

    test('filters stalled tasks (staleness > 1.0)', () async {
      // Task with no effort estimate — staleness = 0 (not stalled)
      await createTask('Fresh');
      // Task with effort=1h, lastProgressAt 100 days ago → stalled
      final stalledTask = await createTask(
        'Old',
        estimatedEffort: 1,
      );
      // Manually save with old lastProgressAt via direct repo access
      final old = stalledTask.copyWith(
        lastProgressAt: DateTime.now().toUtc().subtract(
          const Duration(days: 100),
        ),
      );
      await taskRepo.save(old);

      final tasks = await taskList.execute(
        TaskListParams(projectId: project.id.value, stalled: true),
      );
      expect(tasks, hasLength(1));
      expect(tasks.first.id, stalledTask.id);
    });

    test('returns empty list for invalid context state', () async {
      await createTask('A');
      final tasks = await taskList.execute(
        TaskListParams(
          projectId: project.id.value,
          contextState: 'invalid_context',
        ),
      );
      expect(tasks, isEmpty);
    });

    test('returns empty list for unknown project', () async {
      final tasks = await taskList.execute(
        const TaskListParams(projectId: 'not-a-uuid'),
      );
      expect(tasks, isEmpty);
    });
  });

  // ── LinkListQuery ─────────────────────────────────────────────────────────

  group('LinkListQuery (link_list)', () {
    test('returns all links for a task (both directions)', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      final c = await createTask('C');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id.raw,
          toTaskId: b.id.raw,
          linkType: 'strong',
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: c.id.raw,
          toTaskId: a.id.raw,
          linkType: 'soft',
        ),
      );

      final items = await linkList.execute(
        LinkListParams(taskId: a.id.raw),
      );
      expect(items, hasLength(2));
    });

    test('filters by direction "from"', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      final c = await createTask('C');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id.raw,
          toTaskId: b.id.raw,
          linkType: 'strong',
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: c.id.raw,
          toTaskId: a.id.raw,
          linkType: 'strong',
        ),
      );

      final items = await linkList.execute(
        LinkListParams(taskId: a.id.raw, direction: 'from'),
      );
      expect(items, hasLength(1));
      expect(items.first.task.id, b.id);
    });

    test('filters by direction "to"', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      final c = await createTask('C');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id.raw,
          toTaskId: b.id.raw,
          linkType: 'strong',
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: c.id.raw,
          toTaskId: a.id.raw,
          linkType: 'strong',
        ),
      );

      final items = await linkList.execute(
        LinkListParams(taskId: a.id.raw, direction: 'to'),
      );
      expect(items, hasLength(1));
      expect(items.first.task.id, c.id);
    });

    test('filters by linkType', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      final c = await createTask('C');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id.raw,
          toTaskId: b.id.raw,
          linkType: 'strong',
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id.raw,
          toTaskId: c.id.raw,
          linkType: 'soft',
        ),
      );

      final items = await linkList.execute(
        LinkListParams(taskId: a.id.raw, linkType: 'soft'),
      );
      expect(items, hasLength(1));
      expect(items.first.task.id, c.id);
    });

    test('returns empty list for invalid taskId', () async {
      final items = await linkList.execute(
        const LinkListParams(taskId: 'not-a-uuid'),
      );
      expect(items, isEmpty);
    });

    test('returns empty list for invalid direction', () async {
      final a = await createTask('A');
      final items = await linkList.execute(
        LinkListParams(taskId: a.id.raw, direction: 'sideways'),
      );
      expect(items, isEmpty);
    });
  });

  // ── TaskShowQuery ─────────────────────────────────────────────────────────

  group('TaskShowQuery (task_show)', () {
    test('returns task details with ep and staleness', () async {
      final task = await createTask('Show Me', bv: 80, us: 60);
      final result = await taskShow.execute(
        TaskShowParams(
          projectId: project.id.value,
          ref: task.id.raw,
        ),
      );
      expect(result, isNotNull);
      expect(result!.task.id, task.id);
      expect(result.ep, closeTo(80 * 0.85 + 60 * 0.15, 0.001));
      expect(result.staleness, 0);
    });

    test('applies Hard Cap: child ep = min(parent ep, own ep)', () async {
      final parent = await createTask('Parent', bv: 40, us: 40);
      final child = await createTask(
        'Child',
        bv: 90,
        us: 90,
        parentId: parent.id.raw,
      );

      final result = await taskShow.execute(
        TaskShowParams(
          projectId: project.id.value,
          ref: child.id.raw,
        ),
      );
      expect(result, isNotNull);
      // ep(parent) = 40*0.85 + 40*0.15 = 40.0
      // own_ep(child) = 90*0.85 + 90*0.15 = 90.0
      // Hard Cap: min(40, 90) = 40
      expect(result!.ep, closeTo(40.0, 0.001));
    });

    test('returns null for unknown task ref', () async {
      final result = await taskShow.execute(
        TaskShowParams(
          projectId: project.id.value,
          ref: TaskId.generate().raw,
        ),
      );
      expect(result, isNull);
    });

    test('returns null for invalid project ID', () async {
      final result = await taskShow.execute(
        const TaskShowParams(
          projectId: 'not-a-uuid',
          ref: 'anything',
        ),
      );
      expect(result, isNull);
    });

    test('softContext is populated from soft links', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: b.id.raw,
          toTaskId: a.id.raw,
          linkType: 'soft',
        ),
      );

      final result = await taskShow.execute(
        TaskShowParams(
          projectId: project.id.value,
          ref: a.id.raw,
        ),
      );
      expect(result, isNotNull);
      expect(result!.softContext.informs.map((t) => t.id), contains(b.id));
    });

    test('resolves by alias', () async {
      final task = await createTask('Show By Alias');
      await renameAlias.execute(
        TaskRenameAliasCommand(
          taskId: task.id.raw,
          alias: 'show-by-alias',
        ),
      );
      final result = await taskShow.execute(
        TaskShowParams(
          projectId: project.id.value,
          ref: 'show-by-alias',
        ),
      );
      expect(result, isNotNull);
      expect(result!.task.id, task.id);
    });
  });
}
