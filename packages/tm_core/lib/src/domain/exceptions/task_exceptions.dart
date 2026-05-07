import '../value_objects/task/task_id.dart';

class TaskNotFoundException implements Exception {
  const TaskNotFoundException(this.id);
  final TaskId id;

  @override
  String toString() => 'TaskNotFoundException: Task not found for ref "$id"';
}
