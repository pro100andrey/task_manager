import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_switch_command.dart';
import 'failures/project_switch_failure.dart';
import 'policy/project_switch_exists_policy.dart';

abstract class ProjectSwitchOperationBase
    extends Operation<ProjectSwitchCommand, Project, ProjectSwitchFailure> {
  ProjectSwitchOperationBase(super.pipeline);
}

class ProjectSwitchOperation extends ProjectSwitchOperationBase {
  ProjectSwitchOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'ProjectSwitchOperation';

  @override
  Map<String, dynamic> traceAttributes(ProjectSwitchCommand command) => {
    'projectId': command.projectId,
  };

  @override
  OperationPolicySet<ProjectSwitchCommand, ProjectSwitchFailure>
  preconditionPolicies(
    ProjectSwitchCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    ProjectSwitchExistsPolicy<ProjectSwitchCommand>(
      _repository,
      (cmd) => cmd.projectId,
    ),
  ]);

  @override
  Future<Result<Project, ProjectSwitchFailure>> run(
    ProjectSwitchCommand command,
  ) async {
    final previousProject = await _repository.getCurrentProject();
    final id = ProjectId(command.projectId);
    final current = await _repository.switchCurrentProject(id);

    await _bus.publish(
      ProjectSwitchedEvent(
        previousProject: previousProject,
        currentProject: current,
      ),
    );

    return Success(current);
  }
}
