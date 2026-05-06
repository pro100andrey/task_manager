import '../enums/reflection_source.dart';
import '../enums/reflection_type.dart';
import '../value_objects/project/project_id.dart';
import '../value_objects/reflection/reflection_id.dart';
import '../value_objects/task/task_id.dart';

class Reflection {
  const Reflection({
    required this.id,
    required this.projectId,
    required this.content,
    required this.reflectionType,
    required this.triggeredReplan,
    required this.reflectionBudget,
    required this.createdAt,
    required this.source,
    this.taskId,
  });

  final ReflectionId id;
  final ProjectId projectId;
  final TaskId? taskId;
  final String content;
  final ReflectionType reflectionType;
  final bool triggeredReplan;
  final int reflectionBudget;
  final DateTime createdAt;
  final ReflectionSource source;
}
