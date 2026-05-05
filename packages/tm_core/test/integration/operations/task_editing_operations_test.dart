import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_tasks_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/application/operations/operation_pipeline.dart';
import 'package:tm_core/src/application/operations/project/commands/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/application/operations/task/commands/task_create_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_move_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_rename_alias_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_set_context_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_update_command.dart';
import 'package:tm_core/src/application/operations/task/failures/task_move_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_rename_alias_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_set_context_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_update_failure.dart';
import 'package:tm_core/src/application/operations/task/task_create_operation.dart';
import 'package:tm_core/src/application/operations/task/task_move_operation.dart';
import 'package:tm_core/src/application/operations/task/task_rename_alias_operation.dart';
import 'package:tm_core/src/application/operations/task/task_set_context_operation.dart';
import 'package:tm_core/src/application/operations/task/task_update_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/entities/task.dart';
import 'package:tm_core/src/domain/enums/task_context_state.dart';
import 'package:tm_core/src/domain/events/domain_event.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late OperationPipeline pipeline;
  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskUpdateOperation taskUpdate;
  late TaskSetContextOperation taskSetContext;
  late TaskMoveOperation taskMove;
  late TaskRenameAliasOperation taskRenameAlias;

  late Project project;
  late Task taskA;
  late Task taskB;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl()),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    taskUpdate = TaskUpdateOperation(pipeline, taskRepo, bus);
    taskSetContext = TaskSetContextOperation(pipeline, taskRepo, bus);
    taskMove = TaskMoveOperation(pipeline, taskRepo, bus);
    taskRenameAlias = TaskRenameAliasOperation(pipeline, taskRepo, bus);

    final projResult = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('My Project')),
    );
    project = (projResult as Success<Project, dynamic>).value;

    Future<Task> createTask(String title) async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: title),
      );
      return (r as Success<Task, dynamic>).value;
    }

    taskA = await createTask('Task A');
    taskB = await createTask('Task B');
  });

  tearDown(() => bus.dispose());

  // ---------------------------------------------------------------------------
  group('TaskUpdateOperation', () {
    test('updates title successfully', () async {
      final result = await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, title: 'New Title'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.title.raw, 'New Title');
    });

    test('updates multiple fields at once', () async {
      final result = await taskUpdate.execute(
        TaskUpdateCommand(
          taskId: taskA.id.raw,
          businessValue: 80,
          urgencyScore: 60,
          estimatedEffort: 2.5,
          assignedTo: 'alice',
          tags: ['backend', 'api'],
        ),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.businessValue, 80);
      expect(task.urgencyScore, 60);
      expect(task.estimatedEffort, 2.5);
      expect(task.assignedTo, 'alice');
      expect(task.tags, ['backend', 'api']);
    });

    test('clears dueDate when clearDueDate=true', () async {
      final due = DateTime(2025, 12, 31).toUtc();
      await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, dueDate: due),
      );
      final cleared = await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, clearDueDate: true),
      );
      final task = (cleared as Success<Task, dynamic>).value;
      expect(task.dueDate, isNull);
    });

    test('clears description when clearDescription=true', () async {
      await taskUpdate.execute(
        TaskUpdateCommand(
          taskId: taskA.id.raw,
          description: 'Some description',
        ),
      );
      final cleared = await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, clearDescription: true),
      );
      final task = (cleared as Success<Task, dynamic>).value;
      expect(task.description, isNull);
    });

    test('returns TaskUpdateNotFound for unknown id', () async {
      final result = await taskUpdate.execute(
        TaskUpdateCommand(taskId: TaskId.generate().raw, title: 'X'),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskUpdateFailure>).error,
        isA<TaskUpdateNotFound>(),
      );
    });

    test('rejects invalid businessValue > 100', () async {
      final result = await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, businessValue: 150),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskUpdateFailure>).error,
        isA<TaskUpdateInvalidBusinessValue>(),
      );
    });

    test('rejects invalid urgencyScore < 0', () async {
      final result = await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, urgencyScore: -5),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskUpdateFailure>).error,
        isA<TaskUpdateInvalidUrgencyScore>(),
      );
    });

    test('publishes TaskUpdatedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await taskUpdate.execute(
        TaskUpdateCommand(taskId: taskA.id.raw, urgencyScore: 50),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<TaskUpdatedEvent>());
      final e = events.first as TaskUpdatedEvent;
      expect(e.taskId, taskA.id);
    });
  });

  // ---------------------------------------------------------------------------
  group('TaskSetContextOperation', () {
    test('changes contextState to backlog', () async {
      final result = await taskSetContext.execute(
        TaskSetContextCommand(
          taskId: taskA.id.raw,
          contextState: TaskContextState.backlog.value,
        ),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.contextState, TaskContextState.backlog);
    });

    test('changes contextState to inReview', () async {
      final result = await taskSetContext.execute(
        TaskSetContextCommand(
          taskId: taskA.id.raw,
          contextState: TaskContextState.inReview.value,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<Task, dynamic>).value.contextState,
        TaskContextState.inReview,
      );
    });

    test('returns TaskSetContextNotFound for unknown id', () async {
      final result = await taskSetContext.execute(
        TaskSetContextCommand(
          taskId: TaskId.generate().raw,
          contextState: 'active',
        ),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskSetContextFailure>).error,
        isA<TaskSetContextNotFound>(),
      );
    });

    test('returns TaskSetContextInvalidState for bad value', () async {
      final result = await taskSetContext.execute(
        TaskSetContextCommand(
          taskId: taskA.id.raw,
          contextState: 'definitely-not-valid',
        ),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskSetContextFailure>).error,
        isA<TaskSetContextInvalidState>(),
      );
    });

    test('publishes TaskContextChangedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await taskSetContext.execute(
        TaskSetContextCommand(
          taskId: taskA.id.raw,
          contextState: TaskContextState.backlog.value,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<TaskContextChangedEvent>());
      final e = events.first as TaskContextChangedEvent;
      expect(e.taskId, taskA.id);
      expect(e.contextState, TaskContextState.backlog.value);
    });
  });

  // ---------------------------------------------------------------------------
  group('TaskMoveOperation', () {
    test('moves taskB under taskA as parent', () async {
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw, newParentId: taskA.id.raw),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.parentId, taskA.id);
    });

    test('moves task to root (null parent)', () async {
      // First set a parent
      await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw, newParentId: taskA.id.raw),
      );
      // Then clear it
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.parentId, isNull);
    });

    test('returns TaskMoveNotFound for unknown task', () async {
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: TaskId.generate().raw),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskMoveFailure>).error,
        isA<TaskMoveNotFound>(),
      );
    });

    test('returns TaskMoveParentNotFound for unknown parent', () async {
      final result = await taskMove.execute(
        TaskMoveCommand(
          taskId: taskA.id.raw,
          newParentId: TaskId.generate().raw,
        ),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskMoveFailure>).error,
        isA<TaskMoveParentNotFound>(),
      );
    });

    test('returns TaskMoveSelfParent when task is its own parent', () async {
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: taskA.id.raw, newParentId: taskA.id.raw),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskMoveFailure>).error,
        isA<TaskMoveSelfParent>(),
      );
    });

    test('detects cycle: A→B, then try to make A child of B', () async {
      // Make B a child of A
      await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw, newParentId: taskA.id.raw),
      );
      // Now try to make A a child of B → would create A→B→A cycle
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: taskA.id.raw, newParentId: taskB.id.raw),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskMoveFailure>).error,
        isA<TaskMoveWouldCreateCycle>(),
      );
    });

    test('detects deeper cycle A→B→C, then try to make A child of C', () async {
      // Create third task C
      final rC = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Task C'),
      );
      final taskC = (rC as Success<Task, dynamic>).value;

      // A → B → C
      await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw, newParentId: taskA.id.raw),
      );
      await taskMove.execute(
        TaskMoveCommand(taskId: taskC.id.raw, newParentId: taskB.id.raw),
      );

      // Try C → A (would create cycle A→B→C→A)
      final result = await taskMove.execute(
        TaskMoveCommand(taskId: taskA.id.raw, newParentId: taskC.id.raw),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskMoveFailure>).error,
        isA<TaskMoveWouldCreateCycle>(),
      );
    });

    test(
      'returns TaskMoveCrossProject when parent in different project',
      () async {
        final projResult2 = await projectCreate.execute(
          const ProjectCreateCommand(name: .new('Project 2')),
        );
        final project2 = (projResult2 as Success<Project, dynamic>).value;
        final rX = await taskCreate.execute(
          TaskCreateCommand(projectId: project2.id.value, title: 'Task X'),
        );
        final taskX = (rX as Success<Task, dynamic>).value;

        final result = await taskMove.execute(
          TaskMoveCommand(taskId: taskA.id.raw, newParentId: taskX.id.raw),
        );
        expect(result.isFailure, isTrue);
        expect(
          (result as Failure<Task, TaskMoveFailure>).error,
          isA<TaskMoveCrossProject>(),
        );
      },
    );

    test('publishes TaskMovedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await taskMove.execute(
        TaskMoveCommand(taskId: taskB.id.raw, newParentId: taskA.id.raw),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<TaskMovedEvent>());
      final e = events.first as TaskMovedEvent;
      expect(e.taskId, taskB.id);
      expect(e.newParentId, taskA.id);
    });
  });

  // ---------------------------------------------------------------------------
  group('TaskRenameAliasOperation', () {
    test('sets a new alias on a task', () async {
      final result = await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'my-feature'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.alias?.raw, 'my-feature');
      expect(task.normalizedAlias, 'my-feature');
    });

    test('normalizes alias to lower-kebab-case', () async {
      final result = await taskRenameAlias.execute(
        TaskRenameAliasCommand(
          taskId: taskA.id.raw,
          alias: '  My Feature Task  ',
        ),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.normalizedAlias, 'my-feature-task');
    });

    test('clears alias when null is passed', () async {
      await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'some-alias'),
      );
      final result = await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, dynamic>).value;
      expect(task.alias, isNull);
      expect(task.normalizedAlias, isNull);
    });

    test('returns TaskRenameAliasNotFound for unknown task', () async {
      final result = await taskRenameAlias.execute(
        TaskRenameAliasCommand(
          taskId: TaskId.generate().raw,
          alias: 'something',
        ),
      );
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskRenameAliasFailure>).error,
        isA<TaskRenameAliasNotFound>(),
      );
    });

    test(
      'returns TaskRenameAliasInvalidAlias for alias that normalizes empty',
      () async {
        final result = await taskRenameAlias.execute(
          TaskRenameAliasCommand(
            taskId: taskA.id.raw,
            alias: '---',
          ),
        );
        expect(result.isFailure, isTrue);
        expect(
          (result as Failure<Task, TaskRenameAliasFailure>).error,
          isA<TaskRenameAliasInvalidAlias>(),
        );
      },
    );

    test(
      'returns TaskRenameAliasAlreadyExists when alias taken by other task',
      () async {
        // Set alias on taskB first
        await taskRenameAlias.execute(
          TaskRenameAliasCommand(taskId: taskB.id.raw, alias: 'shared-alias'),
        );

        // Try same alias on taskA
        final result = await taskRenameAlias.execute(
          TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'shared-alias'),
        );
        expect(result.isFailure, isTrue);
        final err =
            (result as Failure<Task, TaskRenameAliasFailure>).error
                as TaskRenameAliasAlreadyExists;
        expect(err.alias, 'shared-alias');
      },
    );

    test('allows re-setting same alias on the same task', () async {
      await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'my-alias'),
      );
      final result = await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'my-alias'),
      );
      expect(result.isSuccess, isTrue);
    });

    test('publishes TaskAliasRenamedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await taskRenameAlias.execute(
        TaskRenameAliasCommand(taskId: taskA.id.raw, alias: 'feature-x'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<TaskAliasRenamedEvent>());
      final e = events.first as TaskAliasRenamedEvent;
      expect(e.taskId, taskA.id);
      expect(e.newAlias, 'feature-x');
    });
  });
}
