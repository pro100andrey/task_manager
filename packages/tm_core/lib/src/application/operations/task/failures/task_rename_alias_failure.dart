sealed class TaskRenameAliasFailure {
  const TaskRenameAliasFailure();
}

final class TaskRenameAliasNotFound extends TaskRenameAliasFailure {
  const TaskRenameAliasNotFound(this.taskId);
  final String taskId;
}

final class TaskRenameAliasInvalidAlias extends TaskRenameAliasFailure {
  const TaskRenameAliasInvalidAlias(this.reason);
  final String reason;
}

final class TaskRenameAliasAlreadyExists extends TaskRenameAliasFailure {
  const TaskRenameAliasAlreadyExists(this.alias);
  final String alias;
}
