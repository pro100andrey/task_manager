import 'package:test/test.dart';
import 'package:tm_core/src/domain/entities/task.dart';
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
    lastProgressAt: now,
    createdAt: now,
    updatedAt: now,
    tags: const [],
    metadata: const {},
    planVersion: 1,
    parentId: parentId,
  );
}

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
}
