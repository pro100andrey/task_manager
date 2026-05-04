import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/application/operations/operation_pipeline.dart';
import 'package:tm_core/src/application/operations/project/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_failure.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/exceptions/project_exceptions.dart';
import 'package:tm_core/src/domain/result.dart';

void main() {
  late ProjectCreateOperation op;
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl repo;

  setUp(() {
    bus = DomainEventBusImpl();
    repo = MemProjectsRepositoryImpl();
    final pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl()),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);
    op = ProjectCreateOperation(pipeline, repo, bus);
  });

  tearDown(() => bus.dispose());

  group('ProjectCreateOperation', () {
    test('creates a project and returns Success', () async {
      final result = await op.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );

      expect(result.isSuccess, isTrue);
      final project = (result as Success<Project, ProjectCreateFailure>).value;
      expect(project.name.raw, 'Alpha');
    });

    test('returns Failure when name already exists', () async {
      await op.execute(const ProjectCreateCommand(name: 'Alpha'));
      final second = await op.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );

      expect(second.isFailure, isTrue);
      final err = (second as Failure<Project, ProjectCreateFailure>).error;
      expect(err, isA<ProjectCreateNameAlreadyExists>());
      final duplicate = err as ProjectCreateNameAlreadyExists;
      expect(duplicate.name, 'Alpha');
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
      final project = (result as Success<Project, ProjectCreateFailure>).value;
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
      final project = (r as Success<Project, ProjectCreateFailure>).value;

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
