import '../../command.dart';

class TaskDoneCommand extends Command {
  const TaskDoneCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
