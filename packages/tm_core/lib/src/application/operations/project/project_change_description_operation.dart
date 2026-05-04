import '../../../domain/entities/project.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_description.dart';
import '../../../domain/value_objects/project/project_id.dart';
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
  );

  final ProjectRepository _repository;

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

    return Success(saved);
  }
}
