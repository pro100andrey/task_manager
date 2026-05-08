import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../events/event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_delete_command.dart';
import 'failures/project_delete_failure.dart';
import 'policy/project_delete_exists_policy.dart';

typedef _Operation =
    Operation<ProjectDeleteCommand, void, ProjectDeleteFailure>;

class ProjectDeleteOperation extends _Operation {
  ProjectDeleteOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final EventBus _bus;

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
    ProjectDeleteExistsPolicy(_repository, (cmd) => cmd.projectId.value),
  ]);

  @override
  Future<Result<void, ProjectDeleteFailure>> run(
    ProjectDeleteCommand command,
  ) async {
    await _repository.delete(command.projectId);
    await _bus.publish(ProjectDeletedEvent(projectId: command.projectId));

    return const Success(null);
  }
}
