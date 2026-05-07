import 'package:test/test.dart';
import 'package:tm_core/src/domain/entities/task.dart';
import 'package:tm_core/src/domain/entities/task_link.dart';
import 'package:tm_core/src/domain/enums/link_type.dart';
import 'package:tm_core/src/domain/enums/task_completion_policy.dart';
import 'package:tm_core/src/domain/enums/task_context_state.dart';
import 'package:tm_core/src/domain/enums/task_last_action_type.dart';
import 'package:tm_core/src/domain/enums/task_status.dart';
import 'package:tm_core/src/domain/exceptions/task_exceptions.dart';
import 'package:tm_core/src/domain/services/task_domain_services.dart';
import 'package:tm_core/src/domain/value_objects/project/project_id.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';
import 'package:tm_core/src/domain/value_objects/task/task_title.dart';

Task _makeTask({
  TaskId? id,
  TaskId? parentId,
  TaskStatus status = TaskStatus.pending,
  TaskCompletionPolicy policy = TaskCompletionPolicy.manual,
  double? estimatedEffort,
  DateTime? lastProgressAt,
}) {
  final now = DateTime.now().toUtc();
  return Task(
    id: id ?? TaskId.generate(),
    projectId: ProjectId.generate(),
    title: TaskTitle('Test'),
    status: status,
    contextState: TaskContextState.active,
    completionPolicy: policy,
    businessValue: 0,
    urgencyScore: 0,
    lastActionType: TaskLastActionType.planning,
    lastProgressAt: lastProgressAt ?? now,
    createdAt: now,
    updatedAt: now,
    tags: const [],
    metadata: const {},
    planVersion: 1,
    parentId: parentId,
    estimatedEffort: estimatedEffort,
  );
}

TaskLink _makeLink({
  required TaskId from,
  required TaskId to,
  LinkType type = LinkType.strong,
  String? label,
}) => TaskLink(
  id: 'link-$from-$to',
  fromTaskId: from,
  toTaskId: to,
  linkType: type,
  createdAt: DateTime.now().toUtc(),
  label: label,
);

void main() {
  group('normalizeAlias', () {
    test('trims whitespace', () {
      expect(normalizeAlias('  hello  '), 'hello');
    });

    test('lowercases', () {
      expect(normalizeAlias('Hello'), 'hello');
    });

    test('replaces spaces with hyphens', () {
      expect(normalizeAlias('hello world'), 'hello-world');
    });

    test('replaces slashes with hyphens', () {
      expect(normalizeAlias('hello/world'), 'hello-world');
    });

    test('removes non-alphanumeric characters except _ and -', () {
      expect(normalizeAlias('hello!@world'), 'helloworld');
    });

    test('strips leading and trailing hyphens', () {
      expect(normalizeAlias('-hello-'), 'hello');
    });

    test('handles complex input', () {
      expect(normalizeAlias('  My Task/Feature #1  '), 'my-task-feature-1');
    });

    test('throws InvalidAliasException for empty result', () {
      expect(
        () => normalizeAlias('!!!'),
        throwsA(isA<InvalidAliasException>()),
      );
    });

    test('throws InvalidAliasException for whitespace-only input', () {
      expect(
        () => normalizeAlias('   '),
        throwsA(isA<InvalidAliasException>()),
      );
    });
  });

  group('isCompletable', () {
    test('always completable when no children', () {
      final task = _makeTask(policy: TaskCompletionPolicy.allChildren);
      expect(isCompletable(task, [task]), isTrue);
    });

    test('allChildren: false when some children incomplete', () {
      final parent = _makeTask(policy: TaskCompletionPolicy.allChildren);
      final child1 = _makeTask(
        parentId: parent.id,
        status: TaskStatus.completed,
      );
      final child2 = _makeTask(
        parentId: parent.id,
      );
      expect(isCompletable(parent, [parent, child1, child2]), isFalse);
    });

    test('allChildren: true when all children completed', () {
      final parent = _makeTask(policy: TaskCompletionPolicy.allChildren);
      final child = _makeTask(
        parentId: parent.id,
        status: TaskStatus.completed,
      );
      expect(isCompletable(parent, [parent, child]), isTrue);
    });

    test('anyChild: true when at least one child completed', () {
      final parent = _makeTask(policy: TaskCompletionPolicy.anyChild);
      final child1 = _makeTask(
        parentId: parent.id,
        status: TaskStatus.completed,
      );
      final child2 = _makeTask(
        parentId: parent.id,
      );
      expect(isCompletable(parent, [parent, child1, child2]), isTrue);
    });

    test('anyChild: false when no child completed', () {
      final parent = _makeTask(policy: TaskCompletionPolicy.anyChild);
      final child = _makeTask(
        parentId: parent.id,
      );
      expect(isCompletable(parent, [parent, child]), isFalse);
    });

    test('manual: always completable even with incomplete children', () {
      final parent = _makeTask();
      final child = _makeTask(
        parentId: parent.id,
      );
      expect(isCompletable(parent, [parent, child]), isTrue);
    });
  });

  group('calculateStaleness', () {
    test('returns 0 when estimatedEffort is null', () {
      final task = _makeTask();
      expect(calculateStaleness(task, DateTime.now().toUtc()), 0);
    });

    test('returns 0 when estimatedEffort is zero', () {
      final task = _makeTask(estimatedEffort: 0);
      expect(calculateStaleness(task, DateTime.now().toUtc()), 0);
    });

    test('returns 0 when estimatedEffort is negative', () {
      final task = _makeTask(estimatedEffort: -1);
      expect(calculateStaleness(task, DateTime.now().toUtc()), 0);
    });

    test('returns > 1.0 when elapsed exceeds expected window', () {
      final past = DateTime.now().toUtc().subtract(const Duration(days: 10));
      final task = _makeTask(estimatedEffort: 1, lastProgressAt: past);
      expect(
        calculateStaleness(task, DateTime.now().toUtc()),
        greaterThan(1.0),
      );
    });

    test('returns 0 when lastProgressAt is now', () {
      final now = DateTime.now().toUtc();
      final task = _makeTask(estimatedEffort: 4, lastProgressAt: now);
      expect(calculateStaleness(task, now), 0);
    });
  });

  group('calculateUnblockScore', () {
    test('counts strong links from taskId to non-completed tasks', () {
      final a = TaskId.generate();
      final b = TaskId.generate();
      final c = TaskId.generate();
      final links = [
        _makeLink(from: a, to: b),
        _makeLink(from: a, to: c),
      ];
      expect(calculateUnblockScore(a, links, {}), 2);
    });

    test('excludes completed tasks', () {
      final a = TaskId.generate();
      final b = TaskId.generate();
      final c = TaskId.generate();
      final links = [
        _makeLink(from: a, to: b),
        _makeLink(from: a, to: c),
      ];
      expect(calculateUnblockScore(a, links, {b}), 1);
    });

    test('ignores soft links', () {
      final a = TaskId.generate();
      final b = TaskId.generate();
      final links = [
        _makeLink(from: a, to: b, type: LinkType.soft),
      ];
      expect(calculateUnblockScore(a, links, {}), 0);
    });

    test('returns 0 when no links exist', () {
      final a = TaskId.generate();
      expect(calculateUnblockScore(a, [], {}), 0);
    });
  });

  group('getSoftContext', () {
    late Task taskA;
    late Task taskB;
    late Task taskC;
    late Map<String, Task> taskMap;

    setUp(() {
      taskA = _makeTask();
      taskB = _makeTask();
      taskC = _makeTask();
      taskMap = {
        taskA.id: taskA,
        taskB.id: taskB,
        taskC.id: taskC,
      };
    });

    test('informs: tasks with soft link TO taskId', () {
      final links = [
        _makeLink(from: taskB.id, to: taskA.id, type: LinkType.soft),
      ];
      final ctx = getSoftContext(taskA.id, links, taskMap);
      expect(ctx.informs, [taskB]);
      expect(ctx.informedBy, isEmpty);
    });

    test('informedBy: tasks with soft link FROM taskId', () {
      final links = [
        _makeLink(from: taskA.id, to: taskB.id, type: LinkType.soft),
      ];
      final ctx = getSoftContext(taskA.id, links, taskMap);
      expect(ctx.informedBy, [taskB]);
      expect(ctx.informs, isEmpty);
    });

    test('related: tasks linked with label=related (both directions)', () {
      final links = [
        _makeLink(
          from: taskA.id,
          to: taskB.id,
          type: LinkType.soft,
          label: 'related',
        ),
        _makeLink(
          from: taskC.id,
          to: taskA.id,
          type: LinkType.soft,
          label: 'related',
        ),
      ];
      final ctx = getSoftContext(taskA.id, links, taskMap);
      expect(ctx.related, containsAll([taskB, taskC]));
      expect(ctx.informs, isEmpty);
      expect(ctx.informedBy, isEmpty);
    });

    test('strong links are ignored', () {
      final links = [_makeLink(from: taskB.id, to: taskA.id)];
      final ctx = getSoftContext(taskA.id, links, taskMap);
      expect(ctx.informs, isEmpty);
      expect(ctx.informedBy, isEmpty);
      expect(ctx.related, isEmpty);
    });

    test('returns empty context when no links', () {
      final ctx = getSoftContext(taskA.id, [], taskMap);
      expect(ctx.informs, isEmpty);
      expect(ctx.informedBy, isEmpty);
      expect(ctx.related, isEmpty);
    });
  });
}
