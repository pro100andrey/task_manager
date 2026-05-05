import '../../../../domain/value_objects/project/project_id.dart';
import '../../../ports/project_repository.dart';
import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../failures/project_switch_failure.dart';

class ProjectSwitchExistsPolicy<C>
    extends PreconditionPolicy<C, ProjectSwitchFailure> {
  ProjectSwitchExistsPolicy(this._repository, this._projectIdSelector);

  final ProjectRepository _repository;
  // This selector is only invoked with the same command instance that enters
  // check(), so the generic callback remains type-safe in this usage.
  // ignore: unsafe_variance
  final String Function(C command) _projectIdSelector;

  @override
  Future<Iterable<ProjectSwitchFailure>> check(
    C command,
    OperationContext context,
  ) async {
    final projectId = _projectIdSelector(command);
    final existing = await _repository.getById(ProjectId(projectId));
    if (existing == null) {
      return [ProjectSwitchNotFound(projectId)];
    }
    return const [];
  }
}
