import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/value_objects.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_rename_command.dart';
import 'failures/project_mutation_failure.dart';
import 'policy/project_mutation_exists_policy.dart';

typedef _Operation =
    Operation<ProjectRenameCommand, Project, ProjectMutationFailure>;

class ProjectRenameOperation extends _Operation {
  ProjectRenameOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'ProjectRenameOperation';

  @override
  Map<String, dynamic> traceAttributes(ProjectRenameCommand command) => {
    'projectId': command.projectId,
    'newName': command.newName,
  };

  @override
  OperationPolicySet<ProjectRenameCommand, ProjectMutationFailure>
  preconditionPolicies(
    ProjectRenameCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    ProjectMutationExistsPolicy(_repository, (cmd) => cmd.projectId),
  ]);

  @override
  Future<Result<Project, ProjectMutationFailure>> run(
    ProjectRenameCommand command,
  ) async {
    // Check if the project exists
    final current = await _repository.getById(command.projectId);
    
    if (current == null) {
      return Failure(ProjectMutationNotFound(command.projectId));
    }

    // Check if the new name is already taken by another project
    final existingByName = await _repository.getByRef(
      ProjectRef.name(command.newName),
    );
   
    if (existingByName != null && existingByName.id != command.projectId) {
      return Failure(ProjectMutationNameAlreadyExists(command.newName));
    }

    // If the name is unchanged, return the current project without saving
    if (current.name == command.newName) {
      return Success(current);
    }

    // Update the project's name and save it
    final saved = await _repository.save(
      current.copyWith(name: command.newName),
    );

    // Publish a ProjectRenamedEvent after successful rename
    await _bus.publish(DomainEvent.projectRenamed(project: saved));

    return Success(saved);
  }
}
