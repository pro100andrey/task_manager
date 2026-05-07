import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskDoneCommand extends Command {
  const TaskDoneCommand({required this.taskId, this.reason});
  final TaskId taskId;
  final String? reason;
}
