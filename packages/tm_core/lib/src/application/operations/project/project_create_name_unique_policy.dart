import '../../../domain/exceptions/project_exceptions.dart';
import '../../../domain/value_objects/value_objects.dart';
import '../../ports/project_repository.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'project_create_command.dart';

typedef _Policy =
    OperationPolicy<ProjectCreateCommand, ProjectNameAlreadyExists>;

class ProjectCreateNameUniquePolicy extends _Policy {
  ProjectCreateNameUniquePolicy(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Iterable<ProjectNameAlreadyExists>> check(
    ProjectCreateCommand command,
    OperationContext context,
  ) async {
    final existing = await _repository.getByRef(
      ProjectRef.name(ProjectName(command.name)),
    );

    if (existing != null) {
      return [ProjectNameAlreadyExists(command.name)];
    }

    return const [];
  }
}
