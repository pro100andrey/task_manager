import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../commands/project_create_command.dart';
import '../failures/project_create_failure.dart';

typedef _Policy = Policy<ProjectCreateCommand, ProjectCreateFailure>;

class ProjectCreateInputValidPolicy extends _Policy {
  @override
  Future<Iterable<ProjectCreateFailure>> check(
    ProjectCreateCommand command,
    OperationContext context,
  ) async {
    final failures = <ProjectCreateFailure>[];

    if (command.name.cannotBeEmptyError case final err?) {
      failures.add(ProjectCreateInvalidName(err));
    }

    if (command.description?.cannotBeEmptyError case final err?) {
      failures.add(ProjectCreateInvalidDescription(err));
    }

    if (command.description?.cannotExceedMaxLengthError case final err?) {
      failures.add(ProjectCreateInvalidDescription(err));
    }

    return failures;
  }
}
