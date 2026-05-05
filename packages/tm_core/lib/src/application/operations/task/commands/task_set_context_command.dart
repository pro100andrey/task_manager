import '../../command.dart';

class TaskSetContextCommand extends Command {
  const TaskSetContextCommand({
    required this.taskId,
    required this.contextState,
  });

  final String taskId;
  final String contextState;
}
