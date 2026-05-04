import '../../../domain/entities/project.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_description.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import 'project_change_description_command.dart';
import 'project_mutation_failure.dart';

abstract class ProjectChangeDescriptionOperationBase
    extends
        Operation<
          ProjectChangeDescriptionCommand,
          Project,
          ProjectMutationFailure
        > {
  ProjectChangeDescriptionOperationBase(super.pipeline);
}

class ProjectChangeDescriptionOperation
    extends ProjectChangeDescriptionOperationBase {
  ProjectChangeDescriptionOperation(
    super.pipeline,
    this._repository,
    this._bus,
  );

  final ProjectRepository _repository;
  final DomainEventBus _bus;

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
  Future<Result<Project, ProjectMutationFailure>> handle(
    ProjectChangeDescriptionCommand command,
  ) async {
    final id = ProjectId(command.projectId);
    final current = await _repository.getById(id);

    if (current == null) {
      return Failure(ProjectMutationNotFound(command.projectId));
    }

    final description = command.description == null
        ? null
        : ProjectDescription(command.description!);

    if (current.description == description) {
      return Success(current);
    }

    final saved = await _repository.save(
      current.copyWith(description: description),
    );
    await _bus.publish(DomainEvent.projectDescriptionChanged(project: saved));

    return Success(saved);
  }
}
