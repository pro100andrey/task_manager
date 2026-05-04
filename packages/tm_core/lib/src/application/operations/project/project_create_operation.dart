import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/project_exceptions.dart';
import '../../../domain/results/result.dart';
import '../../../domain/value_objects/project/project_description.dart';
import '../../../domain/value_objects/value_objects.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/tracing_port.dart';
import '../../ports/transaction_port.dart';
import '../../repositories/project_repository.dart';
import '../operation.dart';
import 'project_create_command.dart';

class ProjectCreateOperation
    extends Operation<ProjectCreateCommand, Project, ProjectNameAlreadyExists> {
  ProjectCreateOperation(
    this._transaction,
    this._repository,
    this._bus,
    this._tracing,
  );

  final TransactionPort _transaction;
  final ProjectRepository _repository;
  final DomainEventBus _bus;
  final TracingPort _tracing;

  @override
  Future<Result<Project, ProjectNameAlreadyExists>> execute(
    ProjectCreateCommand command,
  ) => _tracing.trace(
    'ProjectCreateOperation',
    attributes: {'name': command.name},
    () => _transaction.run(() async {
      final projectName = ProjectName(command.name);
      final ref = ProjectRef.name(projectName);
      final existing = await _repository.getByRef(ref);

      if (existing != null) {
        return Failure(ProjectNameAlreadyExists(command.name));
      }

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
    }),
  );
}
