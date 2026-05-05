import '../../domain/entities/task_link.dart';
import '../../domain/enums/link_type.dart';
import '../../domain/value_objects/task/task_id.dart';

abstract class TaskLinkRepository {
  /// Returns all links where [taskId] is either `fromTaskId` or `toTaskId`.
  Future<List<TaskLink>> getByTaskId(TaskId taskId);

  /// Returns all strong links in a project, keyed '
  ///  by `fromTaskId` → `List<toTaskId>`.
  Future<List<TaskLink>> getAllByProjectLinks(List<TaskId> projectTaskIds);

  Future<TaskLink?> get(TaskId from, TaskId to, LinkType type);

  Future<TaskLink> save(TaskLink link);

  Future<void> delete(TaskId from, TaskId to, LinkType? type);
}
