import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/tm_core.dart';

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

  Future<Project> createProject(ProjectName name) async {
    final r = await createOp.execute(ProjectCreateCommand(name: name));
    return (r as Success<Project, dynamic>).value;
  }

  // ─── ProjectDeleteOperation ──────────────────────────────────────────────

  group('ProjectDeleteOperation', () {
    test('deletes an existing project and returns Success(null)', () async {
      final project = await createProject(const .new('ToDelete'));

      final result = await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id),
      );

      expect(result.isSuccess, isTrue);
      expect(await repo.getById(project.id), isNull);
    });

    test('returns ProjectDeleteNotFound for unknown id', () async {
      final project = await createProject(const .new('Ghost'));

      // delete once so it's gone
      await deleteOp.execute(ProjectDeleteCommand(projectId: project.id));

      final second = await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id),
      );

      expect(second.isFailure, isTrue);
      final err = (second as Failure<void, ProjectDeleteFailure>).error;
      expect(err, isA<ProjectDeleteNotFound>());
      expect((err as ProjectDeleteNotFound).ref, project.id);
    });

    test('publishes ProjectDeletedEvent on success', () async {
      final events = <DomainEvent>[];
      bus.listen<DomainEvent>(events.add);

      final project = await createProject(const .new('Evented'));
      events.clear(); // discard ProjectCreatedEvent

      await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id),
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

      final unknownId = ProjectId.generate();
      await deleteOp.execute(
        ProjectDeleteCommand(projectId: unknownId),
      );

      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('clears current project when active project is deleted', () async {
      final project = await createProject(const ProjectName('Active'));
      await repo.switchCurrentProject(project.id);

      expect(await repo.getCurrentProject(), isNotNull);

      await deleteOp.execute(
        ProjectDeleteCommand(projectId: project.id),
      );

      expect(await repo.getCurrentProject(), isNull);
    });
  });

  // ─── ProjectSwitchOperation ──────────────────────────────────────────────

  group('ProjectSwitchOperation', () {
    test('switches to existing project and returns Success(project)', () async {
      final project = await createProject(const .new('Target'));

      final result = await switchOp.execute(
        ProjectSwitchCommand(projectId: project.id.value),
      );

      expect(result.isSuccess, isTrue);
      final current = (result as Success<Project, ProjectSwitchFailure>).value;
      expect(current.id, project.id);
      expect(await repo.getCurrentProject(), isNotNull);
    });

    test('returns ProjectSwitchNotFound for unknown id', () async {
      final unknownId = ProjectId.generate().value;
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

        final first = await createProject(const .new('First'));
        final second = await createProject(const .new('Second'));

        await switchOp.execute(
          ProjectSwitchCommand(projectId: first.id.value),
        );
        await Future<void>.delayed(Duration.zero);
        events.clear();

        await switchOp.execute(
          ProjectSwitchCommand(projectId: second.id.value),
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

        final project = await createProject(const .new('OnlyOne'));
        events.clear();

        await switchOp.execute(
          ProjectSwitchCommand(projectId: project.id.value),
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

      final ghostId = ProjectId.generate().value;
      await switchOp.execute(
        ProjectSwitchCommand(projectId: ghostId),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('updates getCurrentProject after switch', () async {
      final a = await createProject(const .new('A'));
      final b = await createProject(const .new('B'));

      await switchOp.execute(ProjectSwitchCommand(projectId: a.id.value));
      expect((await repo.getCurrentProject())?.id, a.id);

      await switchOp.execute(ProjectSwitchCommand(projectId: b.id.value));
      expect((await repo.getCurrentProject())?.id, b.id);
    });
  });

  // ─── Project.createdAt ───────────────────────────────────────────────────

  group('Project.createdAt', () {
    test('is set to UTC datetime on creation', () async {
      final before = DateTime.now().toUtc();
      final project = await createProject(const .new('Timestamped'));
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
