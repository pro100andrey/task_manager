import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_task_links_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_tasks_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/application/operations/operation_pipeline.dart';
import 'package:tm_core/src/application/operations/project/commands/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/application/operations/task/commands/task_create_command.dart';
import 'package:tm_core/src/application/operations/task/task_create_operation.dart';
import 'package:tm_core/src/application/operations/task_link/commands/task_link_add_command.dart';
import 'package:tm_core/src/application/operations/task_link/commands/task_link_remove_command.dart';
import 'package:tm_core/src/application/operations/task_link/failures/task_link_add_failure.dart';
import 'package:tm_core/src/application/operations/task_link/failures/task_link_remove_failure.dart';
import 'package:tm_core/src/application/operations/task_link/task_link_add_operation.dart';
import 'package:tm_core/src/application/operations/task_link/task_link_remove_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/entities/task.dart';
import 'package:tm_core/src/domain/entities/task_link.dart';
import 'package:tm_core/src/domain/enums/link_type.dart';
import 'package:tm_core/src/domain/events/domain_event.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late MemTaskLinkRepositoryImpl linkRepo;
  late OperationPipeline pipeline;
  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskLinkAddOperation linkAdd;
  late TaskLinkRemoveOperation linkRemove;

  late Project project;
  late Task taskA;
  late Task taskB;
  late Task taskC;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    linkRepo = MemTaskLinkRepositoryImpl();

    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl()),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    linkAdd = TaskLinkAddOperation(pipeline, taskRepo, linkRepo, bus);
    linkRemove = TaskLinkRemoveOperation(pipeline, linkRepo, bus);

    // Create a project and three tasks for use in tests.
    final projResult = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Test Project')),
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
    taskC = await createTask('Task C');
  });

  group('TaskLinkAddOperation', () {
    test('adds a strong link between two tasks', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Success<TaskLink, TaskLinkAddFailure>>());
      final link = (result as Success<TaskLink, TaskLinkAddFailure>).value;
      expect(link.fromTaskId, equals(taskA.id));
      expect(link.toTaskId, equals(taskB.id));
      expect(link.linkType, equals(LinkType.strong));
    });

    test('adds a soft link between two tasks', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'soft',
        ),
      );

      expect(result, isA<Success<TaskLink, TaskLinkAddFailure>>());
      final link = (result as Success<TaskLink, TaskLinkAddFailure>).value;
      expect(link.linkType, equals(LinkType.soft));
    });

    test('adds label when provided', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
          label: 'blocks',
        ),
      );

      expect(result, isA<Success<TaskLink, TaskLinkAddFailure>>());
      final link = (result as Success<TaskLink, TaskLinkAddFailure>).value;
      expect(link.label, equals('blocks'));
    });

    test('fails when fromTaskId does not exist', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: TaskId.generate().raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddFromNotFound>());
    });

    test('fails when toTaskId does not exist', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: TaskId.generate().raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddToNotFound>());
    });

    test('fails on self-reference', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskA.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddSelfReference>());
    });

    test('fails on duplicate link', () async {
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddAlreadyExists>());
    });

    test('fails on invalid link type', () async {
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'invalid',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddInvalidLinkType>());
    });

    test('detects cycle in strong links: A→B→C→A', () async {
      // A → B
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );
      // B → C
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskB.id.raw,
          toTaskId: taskC.id.raw,
          linkType: 'strong',
        ),
      );
      // C → A — should be rejected
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskC.id.raw,
          toTaskId: taskA.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<TaskLink, TaskLinkAddFailure>>());
      final failure = (result as Failure<TaskLink, TaskLinkAddFailure>).error;
      expect(failure, isA<TaskLinkAddCycleDetected>());
    });

    test('allows cycle in soft links', () async {
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'soft',
        ),
      );
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskB.id.raw,
          toTaskId: taskC.id.raw,
          linkType: 'soft',
        ),
      );
      // C → A — allowed for soft
      final result = await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskC.id.raw,
          toTaskId: taskA.id.raw,
          linkType: 'soft',
        ),
      );

      expect(result, isA<Success<TaskLink, TaskLinkAddFailure>>());
    });

    test('publishes TaskLinkAdded event on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      final linkEvents = events.whereType<TaskLinkAddedEvent>().toList();
      expect(linkEvents, hasLength(1));
      expect(linkEvents.first.fromTaskId, equals(taskA.id));
      expect(linkEvents.first.toTaskId, equals(taskB.id));
    });
  });

  group('TaskLinkRemoveOperation', () {
    setUp(() async {
      // Pre-create a strong link A → B
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );
    });

    test('removes an existing link', () async {
      final result = await linkRemove.execute(
        TaskLinkRemoveCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Success<void, TaskLinkRemoveFailure>>());

      // Verify it's gone
      final remaining = await linkRepo.getByTaskId(taskA.id);
      expect(remaining, isEmpty);
    });

    test('removes all link types when linkType is null', () async {
      // Add a soft link as well
      await linkAdd.execute(
        TaskLinkAddCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'soft',
        ),
      );

      final result = await linkRemove.execute(
        TaskLinkRemoveCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          // linkType omitted → remove all
        ),
      );

      expect(result, isA<Success<void, TaskLinkRemoveFailure>>());
      final remaining = await linkRepo.getByTaskId(taskA.id);
      expect(remaining, isEmpty);
    });

    test('fails when link does not exist', () async {
      final result = await linkRemove.execute(
        TaskLinkRemoveCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskC.id.raw,
          linkType: 'strong',
        ),
      );

      expect(result, isA<Failure<void, TaskLinkRemoveFailure>>());
      final failure = (result as Failure<void, TaskLinkRemoveFailure>).error;
      expect(failure, isA<TaskLinkRemoveNotFound>());
    });

    test('fails on invalid link type', () async {
      final result = await linkRemove.execute(
        TaskLinkRemoveCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'bogus',
        ),
      );

      expect(result, isA<Failure<void, TaskLinkRemoveFailure>>());
      final failure = (result as Failure<void, TaskLinkRemoveFailure>).error;
      expect(failure, isA<TaskLinkRemoveInvalidLinkType>());
    });

    test('publishes TaskLinkRemoved event on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      await linkRemove.execute(
        TaskLinkRemoveCommand(
          fromTaskId: taskA.id.raw,
          toTaskId: taskB.id.raw,
          linkType: 'strong',
        ),
      );

      final linkEvents = events.whereType<TaskLinkRemovedEvent>().toList();
      expect(linkEvents, hasLength(1));
      expect(linkEvents.first.fromTaskId, equals(taskA.id));
      expect(linkEvents.first.toTaskId, equals(taskB.id));
    });
  });
}
