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
import 'package:tm_core/src/application/operations/task/commands/task_cancel_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_create_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_delete_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_done_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_fail_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_hold_command.dart';
import 'package:tm_core/src/application/operations/task/commands/task_start_command.dart';
import 'package:tm_core/src/application/operations/task/failures/task_cancel_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_create_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_delete_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_done_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_fail_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_hold_failure.dart';
import 'package:tm_core/src/application/operations/task/failures/task_start_failure.dart';
import 'package:tm_core/src/application/operations/task/task_cancel_operation.dart';
import 'package:tm_core/src/application/operations/task/task_create_operation.dart';
import 'package:tm_core/src/application/operations/task/task_delete_operation.dart';
import 'package:tm_core/src/application/operations/task/task_done_operation.dart';
import 'package:tm_core/src/application/operations/task/task_fail_operation.dart';
import 'package:tm_core/src/application/operations/task/task_hold_operation.dart';
import 'package:tm_core/src/application/operations/task/task_start_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/entities/task.dart';
import 'package:tm_core/src/domain/enums/task_status.dart';
import 'package:tm_core/src/domain/events/domain_event.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/domain/value_objects/project/project_id.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late OperationPipeline pipeline;
  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskStartOperation taskStart;
  late TaskDoneOperation taskDone;
  late TaskFailOperation taskFail;
  late TaskCancelOperation taskCancel;
  late TaskHoldOperation taskHold;
  late TaskDeleteOperation taskDelete;

  late Project project;

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
    taskStart = TaskStartOperation(pipeline, taskRepo, bus);
    taskDone = TaskDoneOperation(pipeline, taskRepo, bus);
    taskFail = TaskFailOperation(pipeline, taskRepo, bus);
    taskCancel = TaskCancelOperation(pipeline, taskRepo, bus);
    taskHold = TaskHoldOperation(pipeline, taskRepo, bus);
    taskDelete = TaskDeleteOperation(pipeline, taskRepo, bus);

    final pr = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('My Project')),
    );
    project = (pr as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  // ─────────────────────────── TaskCreateOperation ───────────────────────────

  group('TaskCreateOperation', () {
    test('creates a task and returns Success', () async {
      final result = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Do something'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskCreateFailure>).value;
      expect(task.title.raw, 'Do something');
      expect(task.status, TaskStatus.pending);
      expect(task.projectId, project.id);
    });

    test('publishes TaskCreatedEvent on success', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'A'),
      );

      expect(events, anyElement(isA<TaskCreatedEvent>()));
    });

    test('returns Failure for empty title', () async {
      final result = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: '  '),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskCreateFailure>).error,
        isA<TaskCreateInvalidTitle>(),
      );
    });

    test('returns Failure when project not found', () async {
      final result = await taskCreate.execute(
        TaskCreateCommand(
          projectId: ProjectId.generate().value,
          title: 'A',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskCreateFailure>).error,
        isA<TaskCreateProjectNotFound>(),
      );
    });

    test('normalizes and stores alias', () async {
      final result = await taskCreate.execute(
        TaskCreateCommand(
          projectId: project.id.value,
          title: 'My Task',
          alias: 'My Task',
        ),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskCreateFailure>).value;
      expect(task.normalizedAlias, 'my-task');
    });

    test('returns Failure when alias already exists', () async {
      await taskCreate.execute(
        TaskCreateCommand(
          projectId: project.id.value,
          title: 'First',
          alias: 'same-alias',
        ),
      );

      final second = await taskCreate.execute(
        TaskCreateCommand(
          projectId: project.id.value,
          title: 'Second',
          alias: 'same-alias',
        ),
      );

      expect(second.isFailure, isTrue);
      expect(
        (second as Failure<Task, TaskCreateFailure>).error,
        isA<TaskCreateAliasAlreadyExists>(),
      );
    });
  });

  // ─────────────────────────── TaskStartOperation ────────────────────────────

  group('TaskStartOperation', () {
    late Task pendingTask;

    setUp(() async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Start me'),
      );
      pendingTask = (r as Success<Task, dynamic>).value;
    });

    test('transitions pending → inProgress', () async {
      final result = await taskStart.execute(
        TaskStartCommand(taskId: pendingTask.id.value),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskStartFailure>).value;
      expect(task.status, TaskStatus.inProgress);
    });

    test('publishes TaskStartedEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await taskStart.execute(TaskStartCommand(taskId: pendingTask.id.value));

      expect(events, anyElement(isA<TaskStartedEvent>()));
    });

    test('returns Failure for not found task', () async {
      final result = await taskStart.execute(
        TaskStartCommand(taskId: TaskId.generate().raw),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskStartFailure>).error,
        isA<TaskStartNotFound>(),
      );
    });

    test('returns Failure for invalid transition (completed)', () async {
      // start → done → try to start again
      await taskStart.execute(TaskStartCommand(taskId: pendingTask.id.value));
      await taskDone.execute(TaskDoneCommand(taskId: pendingTask.id.value));
      final result = await taskStart.execute(
        TaskStartCommand(taskId: pendingTask.id.value),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskStartFailure>).error,
        isA<TaskStartInvalidTransition>(),
      );
    });
  });

  // ─────────────────────────── TaskDoneOperation ─────────────────────────────

  group('TaskDoneOperation', () {
    late Task inProgressTask;

    setUp(() async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Complete me'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      final r2 = await taskStart.execute(TaskStartCommand(taskId: t.id.value));
      inProgressTask = (r2 as Success<Task, dynamic>).value;
    });

    test('transitions inProgress → completed', () async {
      final result = await taskDone.execute(
        TaskDoneCommand(taskId: inProgressTask.id.value),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskDoneFailure>).value;
      expect(task.status, TaskStatus.completed);
      expect(task.completedAt, isNotNull);
    });

    test('publishes TaskCompletedEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await taskDone.execute(TaskDoneCommand(taskId: inProgressTask.id.value));

      expect(events, anyElement(isA<TaskCompletedEvent>()));
    });

    test('returns Failure when not inProgress', () async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Pending'),
      );
      final t = (r as Success<Task, dynamic>).value;

      final result = await taskDone.execute(
        TaskDoneCommand(taskId: t.id.value),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskDoneFailure>).error,
        isA<TaskDoneInvalidTransition>(),
      );
    });
  });

  // ─────────────────────────── TaskFailOperation ─────────────────────────────

  group('TaskFailOperation', () {
    late Task inProgressTask;

    setUp(() async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Fail me'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      final r2 = await taskStart.execute(TaskStartCommand(taskId: t.id.value));
      inProgressTask = (r2 as Success<Task, dynamic>).value;
    });

    test('transitions inProgress → failed', () async {
      final result = await taskFail.execute(
        TaskFailCommand(taskId: inProgressTask.id.value, reason: 'Blocked'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskFailFailure>).value;
      expect(task.status, TaskStatus.failed);
      expect(task.statusReason, 'Blocked');
    });

    test('publishes TaskFailedEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await taskFail.execute(TaskFailCommand(taskId: inProgressTask.id.value));

      expect(events, anyElement(isA<TaskFailedEvent>()));
    });

    test('returns Failure when not inProgress', () async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Pending'),
      );
      final t = (r as Success<Task, dynamic>).value;

      final result = await taskFail.execute(
        TaskFailCommand(taskId: t.id.value),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskFailFailure>).error,
        isA<TaskFailInvalidTransition>(),
      );
    });
  });

  // ─────────────────────────── TaskHoldOperation ─────────────────────────────

  group('TaskHoldOperation', () {
    late Task inProgressTask;

    setUp(() async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Hold me'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      final r2 = await taskStart.execute(TaskStartCommand(taskId: t.id.value));
      inProgressTask = (r2 as Success<Task, dynamic>).value;
    });

    test('transitions inProgress → onHold', () async {
      final result = await taskHold.execute(
        TaskHoldCommand(taskId: inProgressTask.id.value, reason: 'Waiting'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskHoldFailure>).value;
      expect(task.status, TaskStatus.onHold);
    });

    test('publishes TaskPutOnHoldEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await taskHold.execute(TaskHoldCommand(taskId: inProgressTask.id.value));

      expect(events, anyElement(isA<TaskPutOnHoldEvent>()));
    });

    test('returns Failure when not inProgress', () async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Pending'),
      );
      final t = (r as Success<Task, dynamic>).value;

      final result = await taskHold.execute(
        TaskHoldCommand(taskId: t.id.value),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskHoldFailure>).error,
        isA<TaskHoldInvalidTransition>(),
      );
    });
  });

  // ─────────────────────────── TaskCancelOperation ───────────────────────────

  group('TaskCancelOperation', () {
    test('cancels a pending task', () async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Cancel me'),
      );
      final t = (r as Success<Task, dynamic>).value;

      final result = await taskCancel.execute(
        TaskCancelCommand(taskId: t.id.value, reason: 'No longer needed'),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskCancelFailure>).value;
      expect(task.status, TaskStatus.cancelled);
    });

    test('cancels an inProgress task', () async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Cancel me'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      await taskStart.execute(TaskStartCommand(taskId: t.id.value));

      final result = await taskCancel.execute(
        TaskCancelCommand(taskId: t.id.value),
      );

      expect(result.isSuccess, isTrue);
    });

    test('publishes TaskCancelledEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'C'),
      );
      final t = (r as Success<Task, dynamic>).value;
      await taskCancel.execute(TaskCancelCommand(taskId: t.id.value));

      expect(events, anyElement(isA<TaskCancelledEvent>()));
    });

    test('returns Failure when already completed (terminal)', () async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Done'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      await taskStart.execute(TaskStartCommand(taskId: t.id.value));
      await taskDone.execute(TaskDoneCommand(taskId: t.id.value));

      final result = await taskCancel.execute(
        TaskCancelCommand(taskId: t.id.value),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<Task, TaskCancelFailure>).error,
        isA<TaskCancelInvalidTransition>(),
      );
    });
  });

  // ─────────────────────────── TaskDeleteOperation ───────────────────────────

  group('TaskDeleteOperation', () {
    test('deletes an existing task', () async {
      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Delete me'),
      );
      final t = (r as Success<Task, dynamic>).value;

      final result = await taskDelete.execute(
        TaskDeleteCommand(taskId: t.id.value),
      );

      expect(result.isSuccess, isTrue);
      expect(await taskRepo.getById(t.id), isNull);
    });

    test('publishes TaskDeletedEvent', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      final r = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'D'),
      );
      final t = (r as Success<Task, dynamic>).value;
      await taskDelete.execute(TaskDeleteCommand(taskId: t.id.value));

      expect(events, anyElement(isA<TaskDeletedEvent>()));
    });

    test('returns Failure for not found task', () async {
      final result = await taskDelete.execute(
        TaskDeleteCommand(taskId: TaskId.generate().raw),
      );

      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<void, TaskDeleteFailure>).error,
        isA<TaskDeleteNotFound>(),
      );
    });
  });

  // ────────────────────────────── Lifecycle: hold → resume ───────────────────

  group('Task lifecycle: hold → resume', () {
    test('on-hold task can be restarted', () async {
      final r1 = await taskCreate.execute(
        TaskCreateCommand(projectId: project.id.value, title: 'Resume me'),
      );
      final t = (r1 as Success<Task, dynamic>).value;
      await taskStart.execute(TaskStartCommand(taskId: t.id.value));
      await taskHold.execute(TaskHoldCommand(taskId: t.id.value));

      final result = await taskStart.execute(
        TaskStartCommand(taskId: t.id.value),
      );

      expect(result.isSuccess, isTrue);
      final task = (result as Success<Task, TaskStartFailure>).value;
      expect(task.status, TaskStatus.inProgress);
    });
  });
}
