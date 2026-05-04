import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_description.dart';
import '../../../domain/value_objects/value_objects.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'project_create_command.dart';
import 'project_create_failure.dart';
import 'project_create_input_valid_policy.dart';
import 'project_create_name_unique_policy.dart';

typedef _Op = Operation<ProjectCreateCommand, Project, ProjectCreateFailure>;

typedef CreateResult = Result<Project, ProjectCreateFailure>;

class ProjectCreateOperation extends _Op {
  ProjectCreateOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'ProjectCreateOperation';

  @override
  Map<String, dynamic> traceAttributes(ProjectCreateCommand command) => {
    'name': command.name,
  };

  @override
  OperationPolicySet<ProjectCreateCommand, ProjectCreateFailure>
  preconditionPolicies(
    ProjectCreateCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    ProjectCreateInputValidPolicy(),
    ProjectCreateNameUniquePolicy(_repository),
  ]);

  @override
  Future<CreateResult> runCore(
    ProjectCreateCommand command,
  ) async {
    final projectName = ProjectName(command.name);

    final id = ProjectId.generate();
    final desc = command.description != null
        ? ProjectDescription(command.description!)
        : null;

    final project = Project(
      id: id,
      name: projectName,
      description: desc,
    );

    final saved = await _repository.save(project);
    await _bus.publish(ProjectCreatedEvent(project: saved));

    return Success(saved);
  }
}
