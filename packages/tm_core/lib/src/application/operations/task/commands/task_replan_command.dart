import '../../../../../tm_core.dart';
import '../../command.dart';

enum ReplanAction {
  addTask,
  removeTask,
  addLink,
  removeLink,
  updateTask,
  setContext,
  setPriority,
  setPolicy,
}

class ReplanChange {
  const ReplanChange({required this.action, required this.params});

  final ReplanAction action;
  final Map<String, dynamic> params;
}

class TaskReplanCommand extends Command {
  const TaskReplanCommand({
    required this.taskId,
    required this.changes,
    this.reason,
  });

  final TaskId taskId;
  final List<ReplanChange> changes;
  final String? reason;
}
