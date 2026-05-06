import '../../command.dart';

class TaskReflectCommand extends Command {
  const TaskReflectCommand({
    required this.content,
    this.taskId,
    this.reflectionType = 'observation',
    this.reflectionBudget = 3,
    this.triggerReplan = false,
    this.source = 'mcp',
  });

  final String? taskId;
  final String content;
  final String reflectionType;
  final int reflectionBudget;
  final bool triggerReplan;
  final String source;
}
