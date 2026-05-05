import '../../../../domain/value_objects/value_objects.dart';
import '../../../ports/project_repository.dart';
import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../commands/project_create_command.dart';
import '../failures/project_create_failure.dart';

typedef _Policy = OperationPolicy<ProjectCreateCommand, ProjectCreateFailure>;

class ProjectCreateNameUniquePolicy extends _Policy {
  ProjectCreateNameUniquePolicy(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Iterable<ProjectCreateFailure>> check(
    ProjectCreateCommand command,
    OperationContext context,
  ) async {
    final existing = await _repository.getByRef(
      ProjectRef.name(command.name),
    );

    if (existing != null) {
      return [ProjectCreateNameAlreadyExists(command.name)];
    }

    return const [];
  }
}
