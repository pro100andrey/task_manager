import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskCancelCommand extends Command {
  const TaskCancelCommand({required this.taskId, this.reason});
  final TaskId taskId;
  final String? reason;
}
