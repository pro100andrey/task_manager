import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/no_op_transaction_port_impl.dart';
import 'package:tm_core/src/application/operations/operation_pipeline.dart';
import 'package:tm_core/src/application/operations/project/project_change_description_command.dart';
import 'package:tm_core/src/application/operations/project/project_change_description_operation.dart';
import 'package:tm_core/src/application/operations/project/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/application/operations/project/project_mutation_failure.dart';
import 'package:tm_core/src/application/operations/project/project_rename_command.dart';
import 'package:tm_core/src/application/operations/project/project_rename_operation.dart';
import 'package:tm_core/src/application/operations/project/project_update_command.dart';
import 'package:tm_core/src/application/operations/project/project_update_operation.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/exceptions/project_exceptions.dart';
import 'package:tm_core/src/domain/result.dart';

void main() {
  late ProjectCreateOperation createOp;
  late ProjectRenameOperation renameOp;
  late ProjectChangeDescriptionOperation changeDescriptionOp;
  late ProjectUpdateOperation updateOp;
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl repo;

  setUp(() {
    final pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl()),
      TransactionBehavior(NoOpTransactionPortImpl()),
    ]);

    bus = DomainEventBusImpl();
    repo = MemProjectsRepositoryImpl();
    createOp = ProjectCreateOperation(pipeline, repo, bus);
    renameOp = ProjectRenameOperation(pipeline, repo);
    changeDescriptionOp = ProjectChangeDescriptionOperation(pipeline, repo);
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
      final created = await createOp.execute(
        const ProjectCreateCommand(name: 'Alpha', description: 'v1'),
      );
      final createdProject =
          (created as Success<Project, ProjectNameAlreadyExists>).value;
      final projectId = createdProject.id.raw;

      final result = await renameOp.execute(
        ProjectRenameCommand(projectId: projectId, newName: 'Beta'),
      );

      expect(result.isSuccess, isTrue);
      final renamed =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(renamed.name.raw, 'Beta');
    });

    test('ProjectRenameOperation fails on duplicate name', () async {
      await createOp.execute(const ProjectCreateCommand(name: 'Alpha'));
      final second = await createOp.execute(
        const ProjectCreateCommand(name: 'Beta'),
      );
      final secondProject =
          (second as Success<Project, ProjectNameAlreadyExists>).value;
      final secondId = secondProject.id.raw;

      final result = await renameOp.execute(
        ProjectRenameCommand(projectId: secondId, newName: 'Alpha'),
      );

      expect(result.isFailure, isTrue);
      final failure =
          (result as Failure<Project, ProjectMutationFailure>).error;
      expect(failure, isA<ProjectMutationNameAlreadyExists>());
    });

    test('ProjectChangeDescriptionOperation updates description', () async {
      final created = await createOp.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );
      final createdProject =
          (created as Success<Project, ProjectNameAlreadyExists>).value;
      final projectId = createdProject.id.raw;

      final result = await changeDescriptionOp.execute(
        ProjectChangeDescriptionCommand(
          projectId: projectId,
          description: 'Detailed text',
        ),
      );

      expect(result.isSuccess, isTrue);
      final updated =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(updated.description?.raw, 'Detailed text');
    });

    test('ProjectUpdateOperation changes both name and description', () async {
      final created = await createOp.execute(
        const ProjectCreateCommand(name: 'Alpha'),
      );
      final createdProject =
          (created as Success<Project, ProjectNameAlreadyExists>).value;
      final projectId = createdProject.id.raw;

      final result = await updateOp.execute(
        ProjectUpdateCommand(
          projectId: projectId,
          name: 'Omega',
          description: 'final',
        ),
      );

      expect(result.isSuccess, isTrue);
      final updated =
          (result as Success<Project, ProjectMutationFailure>).value;
      expect(updated.name.raw, 'Omega');
      expect(updated.description?.raw, 'final');
    });
  });
}
