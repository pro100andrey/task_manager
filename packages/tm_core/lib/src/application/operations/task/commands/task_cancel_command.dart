import '../../command.dart';

class TaskCancelCommand extends Command {
  const TaskCancelCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
