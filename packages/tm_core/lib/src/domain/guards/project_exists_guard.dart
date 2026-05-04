import '../../application/repositories/project_repository.dart';
import '../exceptions/project_exceptions.dart';
import '../value_objects/project/project_ref.dart';

class ProjectExistsGuard {
  ProjectExistsGuard(this._repo);
  final ProjectRepository _repo;

  Future<void> check(ProjectRef ref) async {
    final project = await _repo.getByRef(ref);
    if (project == null) {
      throw ProjectNotFound(ref.value);
    }
  }
}
