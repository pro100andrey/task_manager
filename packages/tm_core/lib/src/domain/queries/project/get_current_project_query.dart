// get_current_project_query.dart
import '../../../application/repositories/project_repository.dart';
import '../../entities/project.dart';

class GetCurrentProjectQuery {
  GetCurrentProjectQuery(this._repo);
  final ProjectRepository _repo;

  Future<Project?> execute() => _repo.getCurrentProject();
}
