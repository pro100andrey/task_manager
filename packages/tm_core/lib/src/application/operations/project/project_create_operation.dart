import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/value_objects.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/project_create_command.dart';
import 'failures/project_create_failure.dart';
import 'policy/project_create_input_valid_policy.dart';
import 'policy/project_create_name_unique_policy.dart';

typedef _Operation =
    Operation<ProjectCreateCommand, Project, ProjectCreateFailure>;

class ProjectCreateOperation extends _Operation {
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
  Future<Result<Project, ProjectCreateFailure>> run(
    ProjectCreateCommand command,
  ) async {
    final id = ProjectId.generate();
    final projectName = command.name;
    final desc = command.description;

    final project = Project(
      id: id,
      name: projectName,
      createdAt: DateTime.now().toUtc(),
      description: desc,
    );

    final saved = await _repository.save(project);
    await _bus.publish(ProjectCreatedEvent(project: saved));

    return Success(saved);
  }
}
