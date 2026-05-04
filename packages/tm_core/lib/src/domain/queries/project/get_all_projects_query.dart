// get_current_project_query.dart
import '../../../application/repositories/project_repository.dart';
import '../../entities/project.dart';

class GetAllProjectsQuery {
  GetAllProjectsQuery(this._repo);
  final ProjectRepository _repo;

  Future<List<Project>> execute() => _repo.getAllProjects();
}
