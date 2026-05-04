import '../../domain/exceptions/project_exceptions.dart';
import '../../domain/value_objects/project/project_ref.dart';
import '../repositories/project_repository.dart';

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
