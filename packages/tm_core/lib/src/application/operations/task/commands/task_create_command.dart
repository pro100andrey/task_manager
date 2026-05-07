import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskCreateCommand extends Command {
  const TaskCreateCommand({
    required this.projectId,
    required this.title,
    this.description,
    this.parentId,
    this.alias,
    this.tags = const [],
    this.metadata = const {},
    this.businessValue = 50,
    this.urgencyScore = 50,
    this.completionPolicy = .allChildren,
    this.contextState = .active,
    this.estimatedEffort,
    this.dueDate,
    this.assignedTo,
  });

  final ProjectId projectId;
  final String title;
  final String? description;
  final TaskId? parentId;
  final String? alias;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final int businessValue;
  final int urgencyScore;
  final TaskCompletionPolicy completionPolicy;
  final TaskContextState contextState;
  final double? estimatedEffort;
  final DateTime? dueDate;
  final String? assignedTo;
}
