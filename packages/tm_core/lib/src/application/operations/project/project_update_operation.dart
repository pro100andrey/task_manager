import '../../../domain/entities/project.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../ports/project_repository.dart';
import '../operation.dart';
import 'project_change_description_command.dart';
import 'project_change_description_operation.dart';
import 'project_mutation_failure.dart';
import 'project_rename_command.dart';
import 'project_rename_operation.dart';
import 'project_update_command.dart';

abstract class ProjectUpdateOperationBase
    extends Operation<ProjectUpdateCommand, Project, ProjectMutationFailure> {
  ProjectUpdateOperationBase(super.pipeline);
}

class ProjectUpdateOperation extends ProjectUpdateOperationBase {
  ProjectUpdateOperation(
    super.pipeline,
    this._repository,
    this._renameOperation,
    this._changeDescriptionOperation,
  );

  final ProjectRepository _repository;
  final ProjectRenameOperation _renameOperation;
  final ProjectChangeDescriptionOperation _changeDescriptionOperation;

  @override
  String get operationName => 'ProjectUpdateOperation';

  @override
  Map<String, dynamic> traceAttributes(ProjectUpdateCommand command) => {
    'projectId': command.projectId,
    'nameChanged': command.name != null,
    'descriptionChanged': command.description != null,
  };

  @override
  Future<Result<Project, ProjectMutationFailure>> handle(
    ProjectUpdateCommand command,
  ) async {
    var current = await _repository.getById(ProjectId(command.projectId));
    if (current == null) {
      return Failure(ProjectMutationNotFound(command.projectId));
    }

    if (command.name != null) {
      final renameResult = await _renameOperation.handle(
        ProjectRenameCommand(
          projectId: command.projectId,
          newName: command.name!,
        ),
      );
      switch (renameResult) {
        case Success<Project, ProjectMutationFailure>(:final value):
          current = value;
        case Failure<Project, ProjectMutationFailure>(:final error):
          return Failure(error);
      }
    }

    if (command.description != null) {
      final changeDescriptionResult = await _changeDescriptionOperation.handle(
        ProjectChangeDescriptionCommand(
          projectId: command.projectId,
          description: command.description,
        ),
      );
      switch (changeDescriptionResult) {
        case Success<Project, ProjectMutationFailure>(:final value):
          current = value;
        case Failure<Project, ProjectMutationFailure>(:final error):
          return Failure(error);
      }
    }

    return Success(current);
  }
}
