import '../../../../../tm_core.dart';

sealed class TaskCreateFailure {
  const TaskCreateFailure();
}

final class TaskCreateInvalidTitle extends TaskCreateFailure {
  const TaskCreateInvalidTitle(this.reason);
  final String reason;
}

final class TaskCreateInvalidDescription extends TaskCreateFailure {
  const TaskCreateInvalidDescription(this.reason);
  final String reason;
}

final class TaskCreateProjectNotFound extends TaskCreateFailure {
  const TaskCreateProjectNotFound(this.projectId);
  final ProjectId projectId;
}

final class TaskCreateParentNotFound extends TaskCreateFailure {
  const TaskCreateParentNotFound(this.parentId);
  final TaskId parentId;
}

final class TaskCreateAliasAlreadyExists extends TaskCreateFailure {
  const TaskCreateAliasAlreadyExists(this.alias);
  final TaskAlias alias;
}

final class TaskCreateInvalidAlias extends TaskCreateFailure {
  const TaskCreateInvalidAlias(this.reason);
  final String reason;
}
