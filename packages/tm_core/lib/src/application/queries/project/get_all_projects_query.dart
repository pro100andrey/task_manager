// get_current_project_query.dart
import '../../../domain/entities/project.dart';
import '../../ports/project_repository.dart';

class GetAllProjectsQuery {
  GetAllProjectsQuery(this._repo);
  final ProjectRepository _repo;

  Future<List<Project>> execute() => _repo.getAllProjects();
}
