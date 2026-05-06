import '../../command.dart';

class TaskBreakdownSubtask {
  const TaskBreakdownSubtask({
    required this.title,
    this.description,
    this.businessValue = 50,
    this.urgencyScore = 50,
  });

  final String title;
  final String? description;
  final int businessValue;
  final int urgencyScore;
}

class TaskBreakdownCommand extends Command {
  const TaskBreakdownCommand({
    required this.taskId,
    required this.subtasks,
    this.mode = 'parallel',
  });

  final String taskId;
  final String mode;
  final List<TaskBreakdownSubtask> subtasks;
}
