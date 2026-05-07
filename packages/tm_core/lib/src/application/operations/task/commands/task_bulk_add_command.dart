import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskBulkAddTaskSpec {
  const TaskBulkAddTaskSpec({
    required this.title,
    this.parentId,
    this.contextState,
    this.completionPolicy,
    this.businessValue = 50,
    this.urgencyScore = 50,
    this.description,
  });

  final String title;
  final TaskId? parentId;
  final TaskContextState? contextState;
  final TaskCompletionPolicy? completionPolicy;
  final int businessValue;
  final int urgencyScore;
  final String? description;
}

class TaskBulkAddCommand extends Command {
  const TaskBulkAddCommand({
    required this.projectId,
    required this.tasks,
  });

  final ProjectId projectId;
  final List<TaskBulkAddTaskSpec> tasks;
}
