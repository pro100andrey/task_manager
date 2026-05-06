import '../../../../domain/enums/reflection_source.dart';
import '../../../../domain/enums/reflection_type.dart';
import '../../command.dart';

class TaskReflectCommand extends Command {
  const TaskReflectCommand({
    required this.content,
    this.taskId,
    this.reflectionType = ReflectionType.observation,
    this.reflectionBudget = 3,
    this.triggerReplan = false,
    this.source = ReflectionSource.mcp,
  });

  final String? taskId;
  final String content;
  final ReflectionType reflectionType;
  final int reflectionBudget;
  final bool triggerReplan;
  final ReflectionSource source;
}
