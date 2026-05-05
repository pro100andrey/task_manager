import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../commands/task_create_command.dart';
import '../failures/task_create_failure.dart';

typedef _Policy = OperationPolicy<TaskCreateCommand, TaskCreateFailure>;

class TaskCreateInputValidPolicy extends _Policy {
  @override
  Future<Iterable<TaskCreateFailure>> check(
    TaskCreateCommand command,
    OperationContext context,
  ) async {
    final failures = <TaskCreateFailure>[];

    if (command.title.trim().isEmpty) {
      failures.add(const TaskCreateInvalidTitle('Title cannot be empty'));
    }

    if (command.description != null && command.description!.trim().isEmpty) {
      failures.add(
        const TaskCreateInvalidDescription('Description cannot be empty'),
      );
    }

    return failures;
  }
}
