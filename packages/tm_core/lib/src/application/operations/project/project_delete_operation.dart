import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_delete_command.dart';
import 'failures/project_delete_failure.dart';
import 'policy/project_delete_exists_policy.dart';

abstract class ProjectDeleteOperationBase
    extends Operation<ProjectDeleteCommand, void, ProjectDeleteFailure> {
  ProjectDeleteOperationBase(super.pipeline);
}

class ProjectDeleteOperation extends ProjectDeleteOperationBase {
  ProjectDeleteOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'ProjectDeleteOperation';

  @override
  Map<String, dynamic> traceAttributes(ProjectDeleteCommand command) => {
    'projectId': command.projectId,
  };

  @override
  OperationPolicySet<ProjectDeleteCommand, ProjectDeleteFailure>
  preconditionPolicies(
    ProjectDeleteCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    ProjectDeleteExistsPolicy<ProjectDeleteCommand>(
      _repository,
      (cmd) => cmd.projectId,
    ),
  ]);

  @override
  Future<Result<void, ProjectDeleteFailure>> run(
    ProjectDeleteCommand command,
  ) async {
    final id = ProjectId(command.projectId);
    await _repository.delete(id);
    await _bus.publish(ProjectDeletedEvent(projectId: id));

    return const Success(null);
  }
}
