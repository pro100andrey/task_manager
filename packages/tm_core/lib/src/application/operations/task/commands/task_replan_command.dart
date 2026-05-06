import '../../command.dart';

class ReplanChange {
  const ReplanChange({required this.action, required this.params});

  final String action;
  final Map<String, dynamic> params;
}

class TaskReplanCommand extends Command {
  const TaskReplanCommand({
    required this.taskId,
    required this.changes,
    this.reason,
  });

  final String taskId;
  final List<ReplanChange> changes;
  final String? reason;
}
