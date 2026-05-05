import '../../operation_context.dart';
import '../../operation_policy.dart';
import '../commands/project_create_command.dart';
import '../failures/project_create_failure.dart';

typedef _Policy = OperationPolicy<ProjectCreateCommand, ProjectCreateFailure>;

class ProjectCreateInputValidPolicy extends _Policy {
  @override
  Future<Iterable<ProjectCreateFailure>> check(
    ProjectCreateCommand command,
    OperationContext context,
  ) async {
    final failures = <ProjectCreateFailure>[];

    if (command.name.isEmpty) {
      failures.add(
        const ProjectCreateInvalidName('ProjectName cannot be empty'),
      );
    }

    final description = command.description;
    if (description != null) {
      if (description.isEmpty) {
        failures.add(
          const ProjectCreateInvalidDescription(
            'ProjectDescription cannot be empty',
          ),
        );
      } else if (description.length > 500) {
        failures.add(
          const ProjectCreateInvalidDescription(
            'ProjectDescription cannot exceed 500 characters',
          ),
        );
      }
    }

    return failures;
  }
}
