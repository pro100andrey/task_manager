import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/tm_core.dart';

void main() {
  late ProjectCreateOperation createOp;
  late ProjectRenameOperation renameOp;
  late ProjectChangeDescriptionOperation changeDescriptionOp;
  late ProjectUpdateOperation updateOp;
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl repo;

  setUp(() {
    final pipeline = OperationPipeline([
      TracingBehavior(
        LoggingTracingPortImpl(config: const .new()),
      ),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    bus = DomainEventBusImpl();
    repo = MemProjectsRepositoryImpl();
    createOp = ProjectCreateOperation(pipeline, repo, bus);
    renameOp = ProjectRenameOperation(pipeline, repo, bus);
    changeDescriptionOp = ProjectChangeDescriptionOperation(
      pipeline,
      repo,
      bus,
    );
    updateOp = ProjectUpdateOperation(
      pipeline,
      repo,
      renameOp,
      changeDescriptionOp,
    );
  });

  tearDown(() => bus.dispose());

  group('Project mutation operations', () {
    test('ProjectRenameOperation renames project', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      final created = await createOp.execute(
        const ProjectCreateCommand(
          name: .new('Alpha'),
          description: .new('v1'),
        ),
      );
      final createdProject =
          (created as Success<Project, ProjectCreateFailure>).value;
      final projectId = createdProject.id;

      final result = await renameOp.execute(
        ProjectRenameCommand(projectId: projectId, newName: const .new('Beta')),
      );

      expect(result.isSuccess, isTrue);
      final renamed =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(renamed.name, 'Beta');
      expect(events.whereType<ProjectRenamedEvent>(), hasLength(1));
    });

    test('ProjectRenameOperation fails on duplicate name', () async {
      await createOp.execute(const ProjectCreateCommand(name: .new('Alpha')));
      final second = await createOp.execute(
        const ProjectCreateCommand(name: .new('Beta')),
      );
      final secondProject =
          (second as Success<Project, ProjectCreateFailure>).value;
      final secondId = secondProject.id;

      final result = await renameOp.execute(
        ProjectRenameCommand(projectId: secondId, newName: const .new('Alpha')),
      );

      expect(result.isFailure, isTrue);
      final failure =
          (result as Failure<Project, ProjectMutationFailure>).error;
      expect(failure, isA<ProjectMutationNameAlreadyExists>());
    });

    test('ProjectChangeDescriptionOperation updates description', () async {
      final events = <Object>[];
      bus.listen<Object>(events.add);

      final created = await createOp.execute(
        const ProjectCreateCommand(name: .new('Alpha')),
      );
      final createdProject =
          (created as Success<Project, ProjectCreateFailure>).value;
      final projectId = createdProject.id;

      final result = await changeDescriptionOp.execute(
        ProjectChangeDescriptionCommand(
          projectId: projectId,
          description: const .new('Detailed text'),
        ),
      );

      expect(result.isSuccess, isTrue);
      final updated =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(updated.description, 'Detailed text');
      expect(events.whereType<ProjectDescriptionChangedEvent>(), hasLength(1));
    });

    test('ProjectUpdateOperation changes both name and description', () async {
      final created = await createOp.execute(
        const ProjectCreateCommand(name: .new('Alpha')),
      );
      final createdProject =
          (created as Success<Project, ProjectCreateFailure>).value;

      final result = await updateOp.execute(
        ProjectUpdateCommand(
          projectId: createdProject.id,
          name: const .new('Omega'),
          description: const .new('final'),
        ),
      );

      expect(result.isSuccess, isTrue);
      final updated =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(updated.name, 'Omega');
      expect(updated.description, 'final');
    });
  });
}
