sealed class TaskLinkAddFailure {
  const TaskLinkAddFailure();
}

final class TaskLinkAddFromNotFound extends TaskLinkAddFailure {
  const TaskLinkAddFromNotFound(this.taskId);
  final String taskId;
}

final class TaskLinkAddToNotFound extends TaskLinkAddFailure {
  const TaskLinkAddToNotFound(this.taskId);
  final String taskId;
}

final class TaskLinkAddSelfReference extends TaskLinkAddFailure {
  const TaskLinkAddSelfReference(this.taskId);
  final String taskId;
}

final class TaskLinkAddAlreadyExists extends TaskLinkAddFailure {
  const TaskLinkAddAlreadyExists({
    required this.fromTaskId,
    required this.toTaskId,
    required this.linkType,
  });
  final String fromTaskId;
  final String toTaskId;
  final String linkType;
}

final class TaskLinkAddCycleDetected extends TaskLinkAddFailure {
  const TaskLinkAddCycleDetected(this.path);
  final List<String> path;
}

final class TaskLinkAddInvalidLinkType extends TaskLinkAddFailure {
  const TaskLinkAddInvalidLinkType(this.value);
  final String value;
}
