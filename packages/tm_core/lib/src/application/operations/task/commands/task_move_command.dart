import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskMoveCommand extends Command {
  const TaskMoveCommand({required this.taskId, this.newParentId});

  final TaskId taskId;

  /// null = make the task a root task.
  final TaskId? newParentId;
}
