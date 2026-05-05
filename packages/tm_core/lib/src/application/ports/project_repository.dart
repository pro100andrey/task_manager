import '../../domain/entities/project.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/project/project_ref.dart';

abstract class ProjectRepository {
  Future<Project?> getById(ProjectId id);
  Future<Project?> getByRef(ProjectRef ref);
  Future<Project> save(Project project);
  Future<Project?> getCurrentProject();
  Future<Project> switchCurrentProject(ProjectId id);
  Future<List<Project>> getAllProjects();
  Future<void> delete(ProjectId id);
}
