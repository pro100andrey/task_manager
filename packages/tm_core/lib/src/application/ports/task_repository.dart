import '../../domain/entities/task.dart';
import '../../domain/value_objects/task/task_alias.dart';
import '../../domain/value_objects/value_objects.dart';

abstract class TaskRepository {
  Future<Task?> getById(TaskId id);
  Future<List<Task>> getByProjectId(ProjectId projectId);
  Future<Task> save(Task task);
  Future<void> delete(TaskId id);
  Future<Task?> getByAlias(ProjectId projectId, TaskAlias normalizedAlias);
}
