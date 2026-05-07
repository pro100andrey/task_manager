import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskUpdateCommand extends Command {
  const TaskUpdateCommand({
    required this.taskId,
    this.title,
    this.description,
    this.businessValue,
    this.urgencyScore,
    this.estimatedEffort,
    this.dueDate,
    this.assignedTo,
    this.tags,
    this.clearDueDate = false,
    this.clearAssignedTo = false,
    this.clearDescription = false,
  });

  final TaskId taskId;
  final String? title;
  final String? description;
  final int? businessValue;
  final int? urgencyScore;
  final double? estimatedEffort;
  final DateTime? dueDate;
  final String? assignedTo;
  final List<String>? tags;

  /// Set dueDate to null.
  final bool clearDueDate;

  /// Set assignedTo to null.
  final bool clearAssignedTo;

  /// Set description to null.
  final bool clearDescription;
}
