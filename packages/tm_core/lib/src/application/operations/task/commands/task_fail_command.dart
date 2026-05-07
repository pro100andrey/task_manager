import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskFailCommand extends Command {
  const TaskFailCommand({required this.taskId, this.reason});
  final TaskId taskId;
  final String? reason;
}
