import '../../domain/entities/reflection.dart';
import '../../domain/value_objects/project/project_id.dart';
import '../../domain/value_objects/reflection/reflection_id.dart';
import '../../domain/value_objects/task/task_id.dart';

abstract class ReflectionRepository {
  Future<Reflection?> getById(ReflectionId id);
  Future<List<Reflection>> getByTaskId(TaskId taskId);
  Future<List<Reflection>> getByProjectId(ProjectId projectId);
  Future<Reflection> save(Reflection reflection);
}
