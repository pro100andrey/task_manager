import '../../command.dart';

class TaskHoldCommand extends Command {
  const TaskHoldCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
