import '../../../../../tm_core.dart';
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

  final TaskId? taskId;
  final String content;
  final ReflectionType reflectionType;
  final int reflectionBudget;
  final bool triggerReplan;
  final ReflectionSource source;
}
