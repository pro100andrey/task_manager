import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskHoldCommand extends Command {
  const TaskHoldCommand({required this.taskId, this.reason});
  final TaskId taskId;
  final String? reason;
}
