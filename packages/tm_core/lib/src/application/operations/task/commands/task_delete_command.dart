import '../../command.dart';

class TaskDeleteCommand extends Command {
  const TaskDeleteCommand({required this.taskId});
  final String taskId;
}
