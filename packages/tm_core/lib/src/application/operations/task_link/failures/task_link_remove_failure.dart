sealed class TaskLinkRemoveFailure {
  const TaskLinkRemoveFailure();
}

final class TaskLinkRemoveNotFound extends TaskLinkRemoveFailure {
  const TaskLinkRemoveNotFound({
    required this.fromTaskId,
    required this.toTaskId,
    this.linkType,
  });
  final String fromTaskId;
  final String toTaskId;
  final String? linkType;
}

final class TaskLinkRemoveInvalidLinkType extends TaskLinkRemoveFailure {
  const TaskLinkRemoveInvalidLinkType(this.value);
  final String value;
}
