import '../../application/ports/domain_event_bus.dart';
import '../../application/ports/tracing_port.dart';
import '../../application/ports/transaction_port.dart';
import '../../application/repositories/project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/events/domain_event.dart';
import '../../domain/value_objects/project/project_description.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../exceptions/project_exceptions.dart';

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

  Future<Object> execute(String name, {String? description}) => _tracing.trace(
    'ProjectCreateOperation',
    () => _transaction.run(() async {
      final projectName = ProjectName(name);
      final ref = ProjectRef.name(projectName);
      final existing = await _repository.getByRef(ref);

      if (existing != null) {
        return ProjectNameAlreadyExists(name);
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
      _bus.publish(event);

      return saved;
    }),
  );
}
