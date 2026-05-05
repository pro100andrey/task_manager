import '../../../../domain/value_objects/project/project_id.dart';
import '../../../ports/project_repository.dart';
import '../../command.dart';
import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../failures/project_delete_failure.dart';

class ProjectDeleteExistsPolicy<C extends Command>
    extends PreconditionPolicy<C, ProjectDeleteFailure> {
  ProjectDeleteExistsPolicy(this._repository, this._projectIdSelector);

  final ProjectRepository _repository;
  // This selector is only invoked with the same command instance that enters
  // check(), so the generic callback remains type-safe in this usage.
  // ignore: unsafe_variance
  final String Function(C command) _projectIdSelector;

  @override
  Future<Iterable<ProjectDeleteFailure>> check(
    C command,
    OperationContext context,
  ) async {
    final projectId = _projectIdSelector(command);
    final existing = await _repository.getById(ProjectId(projectId));
    if (existing == null) {
      return [ProjectDeleteNotFound(projectId)];
    }
    return const [];
  }
}
