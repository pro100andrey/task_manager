import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/application/operations/operation_pipeline.dart';
import 'package:tm_core/src/application/operations/project/commands/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/commands/project_delete_command.dart';
import 'package:tm_core/src/application/operations/project/commands/project_switch_command.dart';
import 'package:tm_core/src/application/operations/project/failures/project_delete_failure.dart';
import 'package:tm_core/src/application/operations/project/failures/project_switch_failure.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/application/operations/project/project_delete_operation.dart';
import 'package:tm_core/src/application/operations/project/project_switch_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/events/domain_event.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/domain/value_objects/project/project_id.dart';

OperationPipeline _pipeline() => OperationPipeline([
  TracingBehavior(LoggingTracingPortImpl()),
  TransactionBehavior(NoOpTransactionPortImpl()),
]);

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl repo;
  late ProjectCreateOperation createOp;
  late ProjectDeleteOperation deleteOp;
  late ProjectSwitchOperation switchOp;

  setUp(() {
    bus = DomainEventBusImpl();
    repo = MemProjectsRepositoryImpl();
    final pipeline = _pipeline();
    createOp = ProjectCreateOperation(pipeline, repo, bus);
    deleteOp = ProjectDeleteOperation(pipeline, repo, bus);
    switchOp = ProjectSwitchOperation(pipeline, repo, bus);
  });

  tearDown(() => bus.dispose());

  Future<Project> createProject(String name) async {
    final r = await createOp.execute(ProjectCreateCommand(name: name));
    return (r as Success<Project, dynamic>).value;
  }

  // ─── ProjectDeleteOperation ──────────────────────────────────────────────

  group('ProjectDeleteOperation', () {
    test('deletes an existing project and returns Success(null)', () async {
      final project = await createProject('ToDelete');

      final result = await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id.raw),
      );

      expect(result.isSuccess, isTrue);
      expect(await repo.getById(project.id), isNull);
    });

    test('returns ProjectDeleteNotFound for unknown id', () async {
      final project = await createProject('Ghost');
      final id = project.id.raw;

      // delete once so it's gone
      await deleteOp.execute(ProjectDeleteCommand(projectId: id));

      final second = await deleteOp.execute(
        ProjectDeleteCommand(projectId: id),
      );

      expect(second.isFailure, isTrue);
      final err = (second as Failure<void, ProjectDeleteFailure>).error;
      expect(err, isA<ProjectDeleteNotFound>());
      expect((err as ProjectDeleteNotFound).ref, id);
    });

    test('publishes ProjectDeletedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      final project = await createProject('Evented');
      events.clear(); // discard ProjectCreatedEvent

      await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id.raw),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<ProjectDeletedEvent>());
      final deleted = events.first as ProjectDeletedEvent;
      expect(deleted.projectId, project.id);
    });

    test('does not publish event when project not found', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      final unknownId = ProjectId.generate().raw;
      await deleteOp.execute(
        ProjectDeleteCommand(projectId: unknownId),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('clears current project when active project is deleted', () async {
      final project = await createProject('Active');
      await repo.switchCurrentProject(project.id);

      expect(await repo.getCurrentProject(), isNotNull);

      await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id.raw),
      );

      expect(await repo.getCurrentProject(), isNull);
    });
  });

  // ─── ProjectSwitchOperation ──────────────────────────────────────────────

  group('ProjectSwitchOperation', () {
    test('switches to existing project and returns Success(project)', () async {
      final project = await createProject('Target');

      final result = await switchOp.execute(
        ProjectSwitchCommand(projectId: project.id.raw),
      );

      expect(result.isSuccess, isTrue);
      final current = (result as Success<Project, ProjectSwitchFailure>).value;
      expect(current.id, project.id);
      expect(await repo.getCurrentProject(), isNotNull);
    });

    test('returns ProjectSwitchNotFound for unknown id', () async {
      final unknownId = ProjectId.generate().raw;
      final result = await switchOp.execute(
        ProjectSwitchCommand(projectId: unknownId),
      );

      expect(result.isFailure, isTrue);
      final err = (result as Failure<Project, ProjectSwitchFailure>).error;
      expect(err, isA<ProjectSwitchNotFound>());
    });

    test(
      'publishes ProjectSwitchedEvent with correct previous and current',
      () async {
        final events = <DomainEvent>[];
        bus.listen<DomainEvent>(events.add);

        final first = await createProject('First');
        final second = await createProject('Second');

        await switchOp.execute(
          ProjectSwitchCommand(projectId: first.id.raw),
        );
        await Future<void>.delayed(Duration.zero);
        events.clear();

        await switchOp.execute(
          ProjectSwitchCommand(projectId: second.id.raw),
        );
        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        final evt = events.first as ProjectSwitchedEvent;
        expect(evt.previousProject?.id, first.id);
        expect(evt.currentProject.id, second.id);
      },
    );

    test(
      'publishes ProjectSwitchedEvent with null previousProject on first '
      'switch',
      () async {
        final events = <DomainEvent>[];
        bus.listen<DomainEvent>(events.add);

        final project = await createProject('OnlyOne');
        events.clear();

        await switchOp.execute(
          ProjectSwitchCommand(projectId: project.id.raw),
        );
        await Future<void>.delayed(Duration.zero);

        final evt = events.first as ProjectSwitchedEvent;
        expect(evt.previousProject, isNull);
        expect(evt.currentProject.id, project.id);
      },
    );

    test('does not publish event when project not found', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      final ghostId = ProjectId.generate().raw;
      await switchOp.execute(
        ProjectSwitchCommand(projectId: ghostId),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('updates getCurrentProject after switch', () async {
      final a = await createProject('A');
      final b = await createProject('B');

      await switchOp.execute(ProjectSwitchCommand(projectId: a.id.raw));
      expect((await repo.getCurrentProject())?.id, a.id);

      await switchOp.execute(ProjectSwitchCommand(projectId: b.id.raw));
      expect((await repo.getCurrentProject())?.id, b.id);
    });
  });

  // ─── Project.createdAt ───────────────────────────────────────────────────

  group('Project.createdAt', () {
    test('is set to UTC datetime on creation', () async {
      final before = DateTime.now().toUtc();
      final project = await createProject('Timestamped');
      final after = DateTime.now().toUtc();

      expect(project.createdAt.isUtc, isTrue);
      expect(
        project.createdAt.isAfter(before) ||
            project.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        project.createdAt.isBefore(after) ||
            project.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });
}
