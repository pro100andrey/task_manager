import '../../command.dart';

class TaskStartCommand extends Command {
  const TaskStartCommand({required this.taskId, this.reason});
  final String taskId;
  final String? reason;
}
