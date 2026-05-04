// get_current_project_query.dart
import '../../../domain/entities/project.dart';
import '../../repositories/project_repository.dart';

class GetCurrentProjectQuery {
  GetCurrentProjectQuery(this._repo);
  final ProjectRepository _repo;

  Future<Project?> execute() => _repo.getCurrentProject();
}
