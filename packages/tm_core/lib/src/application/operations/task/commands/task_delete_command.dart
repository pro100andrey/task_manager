import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskDeleteCommand extends Command {
  const TaskDeleteCommand({required this.taskId});
  final TaskId taskId;
}
