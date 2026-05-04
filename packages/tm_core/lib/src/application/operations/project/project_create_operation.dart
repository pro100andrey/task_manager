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

class ProjectCreateOperation {
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

  Future<Result<Project, ProjectNameAlreadyExists>> execute(
    String name, {
    String? description,
  }) => _tracing.trace(
    'ProjectCreateOperation',
    attributes: {'name': name},
    () => _transaction.run(() async {
      final projectName = ProjectName(name);
      final ref = ProjectRef.name(projectName);
      final existing = await _repository.getByRef(ref);

      if (existing != null) {
        return Failure(ProjectNameAlreadyExists(name));
      }

      final id = ProjectId.generate();
      final desc = description != null ? ProjectDescription(description) : null;

      final project = Project(
        id: id,
        name: projectName,
        description: desc,
      );

      final saved = await _repository.save(project);
      final event = ProjectCreatedEvent(project: saved);
      await _bus.publish(event);

      return Success(saved);
    }),
  );
}
