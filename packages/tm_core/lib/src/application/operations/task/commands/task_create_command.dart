import '../../../../domain/enums/task_completion_policy.dart';
import '../../../../domain/enums/task_context_state.dart';
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
    this.businessValue = 0,
    this.urgencyScore = 0,
    this.completionPolicy = .manual,
    this.contextState = .active,
    this.estimatedEffort,
    this.dueDate,
    this.assignedTo,
  });

  final String projectId;
  final String title;
  final String? description;
  final String? parentId;
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
