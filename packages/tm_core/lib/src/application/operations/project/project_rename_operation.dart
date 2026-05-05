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
    ProjectMutationExistsPolicy<ProjectRenameCommand>(
      _repository,
      (cmd) => cmd.projectId,
    ),
  ]);

  @override
  Future<Result<Project, ProjectMutationFailure>> run(
    ProjectRenameCommand command,
  ) async {
    final id = ProjectId(command.projectId);
    final current = await _repository.getById(id);

    if (current == null) {
      return Failure(ProjectMutationNotFound(command.projectId));
    }

    final newName = ProjectName(command.newName);
    final existingByName = await _repository.getByRef(ProjectRef.name(newName));
    if (existingByName != null && existingByName.id != id) {
      return Failure(ProjectMutationNameAlreadyExists(command.newName));
    }

    if (current.name == newName) {
      return Success(current);
    }

    final saved = await _repository.save(current.copyWith(name: newName));
    await _bus.publish(DomainEvent.projectRenamed(project: saved));
    return Success(saved);
  }
}
