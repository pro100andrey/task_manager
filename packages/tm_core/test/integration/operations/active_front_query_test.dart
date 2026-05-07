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
  late OperationPipeline pipeline;
  late DomainEventBusImpl bus;

  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskStartOperation taskStart;
  late TaskDoneOperation taskDone;
  late TaskFailOperation taskFail;
  late TaskCancelOperation taskCancel;
  late TaskLinkAddOperation linkAdd;
  late GetActiveFrontQuery query;

  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    linkRepo = MemTaskLinkRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(
        LoggingTracingPortImpl(config: const TracingLoggingConfig()),
      ),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    taskStart = TaskStartOperation(pipeline, taskRepo, bus);
    taskDone = TaskDoneOperation(pipeline, taskRepo, bus);
    taskFail = TaskFailOperation(pipeline, taskRepo, bus);
    taskCancel = TaskCancelOperation(pipeline, taskRepo, bus);
    linkAdd = TaskLinkAddOperation(pipeline, taskRepo, linkRepo, bus);
    query = GetActiveFrontQuery(taskRepo, linkRepo);

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Test Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  Future<Task> createTask(
    String title, {
    int bv = 50,
    int us = 50,
    TaskId? parentId,
    TaskCompletionPolicy completionPolicy = TaskCompletionPolicy.manual,
  }) async {
    final r = await taskCreate.execute(
      TaskCreateCommand(
        projectId: project.id,
        title: title,
        businessValue: bv,
        urgencyScore: us,
        parentId: parentId,
        completionPolicy: completionPolicy,
      ),
    );
    return (r as Success<Task, dynamic>).value;
  }

  GetActiveFrontParams params({
    String contextFilter = 'active',
    int limit = 10,
    bool includeStalled = false,
  }) => GetActiveFrontParams(
    projectId: project.id,
    contextFilter: contextFilter,
    limit: limit,
    includeStalled: includeStalled,
  );

  // ── Basic filtering ────────────────────────────────────────────────────────

  group('basic filtering', () {
    test('returns empty front when no tasks exist', () async {
      final result = await query.execute(params());
      expect(result.front, isEmpty);
      expect(result.blockedByStrong, isEmpty);
      expect(result.waitingChildren, isEmpty);
      expect(result.stalledTasks, isEmpty);
    });

    test('single pending task appears in front', () async {
      final t = await createTask('Task A');
      final result = await query.execute(params());

      expect(result.front, hasLength(1));
      expect(result.front.first.task.id, equals(t.id));
    });

    test('in_progress task does not appear in front', () async {
      final t = await createTask('Task A');
      await taskStart.execute(TaskStartCommand(taskId: t.id));
      final result = await query.execute(params());

      expect(result.front, isEmpty);
    });

    test('completed task does not appear in front', () async {
      final t = await createTask('Task A');
      await taskStart.execute(TaskStartCommand(taskId: t.id));
      await taskDone.execute(TaskDoneCommand(taskId: t.id));
      final result = await query.execute(params());

      expect(result.front, isEmpty);
    });
  });

  // ── Priority and sorting ───────────────────────────────────────────────────

  group('priority sorting', () {
    test('higher BV task appears before lower BV task', () async {
      final low = await createTask('Low BV', bv: 10, us: 10);
      final high = await createTask('High BV', bv: 90, us: 10);

      final result = await query.execute(params());
      expect(result.front.first.task.id, equals(high.id));
      expect(result.front.last.task.id, equals(low.id));
    });

    test('ep is computed correctly: 0.85*BV + 0.15*US', () async {
      await createTask('Task', bv: 80, us: 60);
      final result = await query.execute(params());
      const expected = 80 * 0.85 + 60 * 0.15;
      expect(result.front.first.ep, closeTo(expected, 0.001));
    });

    test('child ep is capped by parent ep (Hard Cap)', () async {
      // Parent: BV=40, own_ep=40*0.85+50*0.15=41.5
      final parent = await createTask('Parent', bv: 40);
      // Child: BV=90 own_ep=90*0.85+50*0.15=84.0 → capped to 41.5
      await createTask('Child', bv: 90, parentId: parent.id);

      final result = await query.execute(params());
      // Both are pending; child should have ep <= parent ep
      final parentItem = result.front.firstWhere((i) => i.task.id == parent.id);
      final childItem = result.front.firstWhere((i) => i.task.id != parent.id);

      expect(childItem.ep, lessThanOrEqualTo(parentItem.ep));
      expect(childItem.ep, closeTo(parentItem.ep, 0.001));
    });

    test('depth is computed correctly for nested tasks', () async {
      final root = await createTask('Root');
      final child = await createTask('Child', parentId: root.id);
      final grand = await createTask('Grand', parentId: child.id);

      final result = await query.execute(params());
      final depths = {for (final i in result.front) i.task.id: i.depth};

      expect(depths[root.id], equals(0));
      expect(depths[child.id], equals(1));
      expect(depths[grand.id], equals(2));
    });

    test(
      'stalled task sorts above non-stalled when EP is equal',
      () async {
        // Both tasks have same BV/US so equal EP.
        // One has estimatedEffort set and old lastProgressAt → stalled.
        final fresh = await createTask('Fresh');
        final stale = await createTask('Stale');

        // Directly save stale task with old lastProgressAt via repo.
        final old = stale.copyWith(
          estimatedEffort: 1,
          lastProgressAt: DateTime.now().toUtc().subtract(
            const Duration(days: 100),
          ),
        );
        await taskRepo.save(old);

        final result = await query.execute(params());

        // stale should appear before fresh
        final ids = result.front.map((i) => i.task.id).toList();
        expect(ids.indexOf(stale.id), lessThan(ids.indexOf(fresh.id)));
      },
    );
  });

  // ── Strong-link blocking ───────────────────────────────────────────────────

  group('strong link blocking', () {
    test('task with unmet prerequisite goes to blockedByStrong', () async {
      // A is a prerequisite of B: link(from=A, to=B)
      final a = await createTask('A');
      final b = await createTask('B');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );

      final result = await query.execute(params());

      // A is in front (no prerequisites), B is blocked
      expect(result.front.map((i) => i.task.id), contains(a.id));
      expect(result.blockedByStrong.map((b2) => b2.task.id), contains(b.id));
    });

    test('task becomes ready when prerequisite is completed', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );

      // Complete A
      await taskStart.execute(TaskStartCommand(taskId: a.id));
      await taskDone.execute(TaskDoneCommand(taskId: a.id));

      final result = await query.execute(params());
      expect(result.front.map((i) => i.task.id), contains(b.id));
      expect(result.blockedByStrong, isEmpty);
    });

    test('failed prerequisite does not unblock dependent task', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );

      await taskStart.execute(TaskStartCommand(taskId: a.id));
      await taskFail.execute(TaskFailCommand(taskId: a.id));

      final result = await query.execute(params());
      expect(result.front.map((i) => i.task.id), isNot(contains(b.id)));
      expect(result.blockedByStrong.map((i) => i.task.id), contains(b.id));
    });

    test('cancelled prerequisite does not unblock dependent task', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );

      await taskCancel.execute(TaskCancelCommand(taskId: a.id));

      final result = await query.execute(params());
      expect(result.front.map((i) => i.task.id), isNot(contains(b.id)));
      expect(result.blockedByStrong.map((i) => i.task.id), contains(b.id));
    });

    test('unblockScore reflects how many tasks depend on this task', () async {
      final a = await createTask('A');
      final b = await createTask('B');
      final c = await createTask('C');
      // A is a prerequisite of both B and C
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: c.id,
          linkType: .strong,
        ),
      );

      final result = await query.execute(params());
      final aItem = result.front.firstWhere((i) => i.task.id == a.id);
      expect(aItem.unblockScore, equals(2));
    });

    test('task with higher unblockScore sorts before equal-ep task', () async {
      // Two tasks with same ep; A unblocks 2 tasks, D unblocks 0
      final a = await createTask('A');
      final b = await createTask('B');
      final d = await createTask('D');
      await createTask('C');

      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: b.id,
          linkType: .strong,
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: a.id,
          toTaskId: d.id,
          linkType: .strong,
        ),
      );

      final result = await query.execute(params());
      final front = result.front;
      final aIdx = front.indexWhere((i) => i.task.id == a.id);
      expect(aIdx, equals(0)); // A sorts first due to unblockScore=2
    });
  });

  // ── waitingChildren ────────────────────────────────────────────────────────

  group('waitingChildren', () {
    test(
      'parent with non-terminal children appears in waitingChildren',
      () async {
        final parent = await taskCreate.execute(
          TaskCreateCommand(
            projectId: project.id,
            title: 'Parent',
          ),
        );
        final parentTask = (parent as Success<Task, dynamic>).value;
        await createTask('Child 1', parentId: parentTask.id);
        await createTask('Child 2', parentId: parentTask.id);

        final result = await query.execute(params());

        expect(
          result.waitingChildren.map((w) => w.task.id),
          contains(parentTask.id),
        );
        expect(
          result.front.map((i) => i.task.id),
          isNot(contains(parentTask.id)),
        );
      },
    );

    test(
      'waiting count equals non-terminal child count for allChildren policy',
      () async {
        final parent = await taskCreate.execute(
          TaskCreateCommand(
            projectId: project.id,
            title: 'Parent',
          ),
        );
        final parentTask = (parent as Success<Task, dynamic>).value;
        final c1 = await createTask('Child 1', parentId: parentTask.id);
        await createTask('Child 2', parentId: parentTask.id);

        // Complete one child
        await taskStart.execute(TaskStartCommand(taskId: c1.id));
        await taskDone.execute(TaskDoneCommand(taskId: c1.id));

        final result = await query.execute(params());
        final waiting = result.waitingChildren.firstWhere(
          (w) => w.task.id == parentTask.id,
        );
        expect(waiting.remaining, equals(1));
      },
    );
  });

  // ── limit ──────────────────────────────────────────────────────────────────

  group('limit parameter', () {
    test('limit=2 returns at most 2 items', () async {
      await createTask('A');
      await createTask('B');
      await createTask('C');

      final result = await query.execute(params(limit: 2));
      expect(result.front, hasLength(2));
    });

    test('limit=0 returns all items', () async {
      await createTask('A');
      await createTask('B');
      await createTask('C');

      final result = await query.execute(params(limit: 0));
      expect(result.front, hasLength(3));
    });
  });

  // ── invalid projectId ──────────────────────────────────────────────────────

  test('invalid projectId returns empty result', () async {
    final result = await query.execute(
      const GetActiveFrontParams(projectId: .new('not-a-uuid')),
    );
    expect(result.front, isEmpty);
  });
}
