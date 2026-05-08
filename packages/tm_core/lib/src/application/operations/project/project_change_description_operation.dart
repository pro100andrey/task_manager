import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../events/event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_change_description_command.dart';
import 'failures/project_mutation_failure.dart';
import 'policy/project_mutation_exists_policy.dart';

typedef _Operation =
    Operation<ProjectChangeDescriptionCommand, Project, ProjectMutationFailure>;

class ProjectChangeDescriptionOperation extends _Operation {
  ProjectChangeDescriptionOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final EventBus _bus;

  @override
  String get operationName => 'ProjectChangeDescriptionOperation';

  @override
  Map<String, dynamic> traceAttributes(
    ProjectChangeDescriptionCommand command,
  ) => {
    'projectId': command.projectId,
    'descriptionChanged': true,
  };

  @override
  OperationPolicySet<ProjectChangeDescriptionCommand, ProjectMutationFailure>
  preconditionPolicies(
    ProjectChangeDescriptionCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    ProjectMutationExistsPolicy(_repository, (cmd) => cmd.projectId),
  ]);

  @override
  Future<Result<Project, ProjectMutationFailure>> run(
    ProjectChangeDescriptionCommand command,
  ) async {
    final current = await _repository.getById(command.projectId);

    if (current == null) {
      return Failure(ProjectMutationNotFound(command.projectId));
    }

    if (current.description == command.description) {
      return Success(current);
    }

    final saved = await _repository.save(
      current.copyWith(description: command.description),
    );

    await _bus.publish(DomainEvent.projectDescriptionChanged(project: saved));

    return Success(saved);
  }
}
