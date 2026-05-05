import '../../command.dart';

class TaskFailCommand extends Command {
  const TaskFailCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
