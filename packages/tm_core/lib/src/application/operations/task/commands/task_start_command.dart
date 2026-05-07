import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskStartCommand extends Command {
  const TaskStartCommand({required this.taskId, this.reason});
  final TaskId taskId;
  final String? reason;
}
