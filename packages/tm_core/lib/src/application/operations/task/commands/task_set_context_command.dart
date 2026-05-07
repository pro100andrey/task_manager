import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskSetContextCommand extends Command {
  const TaskSetContextCommand({
    required this.taskId,
    required this.contextState,
  });

  final TaskId taskId;
  final String contextState;
}
