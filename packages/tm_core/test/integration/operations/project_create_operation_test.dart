import 'package:test/test.dart';
import 'package:tm_core/src/application/operations/project/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/exceptions/project_exceptions.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/infra/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/infra/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/infra/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/infra/tracing/logging_tracing_port.dart';

void main() {
  late ProjectCreateOperation op;
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl repo;

  setUp(() {
    bus = DomainEventBusImpl();
    repo = MemProjectsRepositoryImpl();
    op = ProjectCreateOperation(
      NoOpTransactionPortImpl(),
      repo,
      bus,
      LoggingTracingPortImpl(),
    );
  });

  tearDown(() => bus.dispose());

  group('ProjectCreateOperation', () {
    test('creates a project and returns Success', () async {
      final result = await op.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );

      expect(result.isSuccess, isTrue);
      final project =
          (result as Success<Project, ProjectNameAlreadyExists>).value;
      expect(project.name.raw, 'Alpha');
    });

    test('returns Failure when name already exists', () async {
      await op.execute(const ProjectCreateCommand(name: 'Alpha'));
      final second = await op.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );

      expect(second.isFailure, isTrue);
      final err = (second as Failure<Project, ProjectNameAlreadyExists>).error;
      expect(err.name, 'Alpha');
    });

    test('publishes ProjectCreatedEvent on success', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await op.execute(const ProjectCreateCommand(name: 'Beta'));
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
    });

    test('does not publish event on duplicate name', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      await op.execute(const ProjectCreateCommand(name: 'Beta'));
      await Future<void>.delayed(Duration.zero);
      final before = events.length;

      await op.execute(const ProjectCreateCommand(name: 'Beta'));
      await Future<void>.delayed(Duration.zero);

      expect(events.length, before); // no new event
    });

    test('creates project with description', () async {
      final result = await op.execute(
        const ProjectCreateCommand(name: 'X', description: 'details'),
      );
      final project =
          (result as Success<Project, ProjectNameAlreadyExists>).value;
      expect(project.description?.raw, 'details');
    });

    test('fold helper returns correct branch', () async {
      final result = await op.execute(const ProjectCreateCommand(name: 'Fold'));
      final name = result.fold(
        onSuccess: (p) => p.name.raw,
        onFailure: (_) => 'FAIL',
      );
      expect(name, 'Fold');
    });
  });

  group('MemProjectsRepositoryImpl.getCurrentProject/switchCurrentProject', () {
    test('getCurrentProject returns null when no project selected', () async {
      expect(await repo.getCurrentProject(), isNull);
    });

    test('switchCurrentProject sets current project', () async {
      final r = await op.execute(const ProjectCreateCommand(name: 'Current'));
      final project = (r as Success<Project, ProjectNameAlreadyExists>).value;

      final switched = await repo.switchCurrentProject(project.id);
      expect(switched.name.raw, 'Current');

      final current = await repo.getCurrentProject();
      expect(current?.name.raw, 'Current');
    });

    test('switchCurrentProject throws for unknown id', () async {
      final id = (await op.execute(
        const ProjectCreateCommand(name: 'X'),
      )).fold(onSuccess: (p) => p.id, onFailure: (_) => throw Exception());

      // delete from storage by creating a fresh repo to get an unknown id
      final freshRepo = MemProjectsRepositoryImpl();
      expect(
        () => freshRepo.switchCurrentProject(id),
        throwsA(isA<ProjectNotFound>()),
      );
    });
  });
}
