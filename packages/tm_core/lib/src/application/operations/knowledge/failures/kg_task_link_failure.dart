sealed class KgTaskLinkFailure {
  const KgTaskLinkFailure();
}

final class KgTaskLinkTaskNotFound extends KgTaskLinkFailure {
  const KgTaskLinkTaskNotFound(this.taskId);
  final String taskId;
}

final class KgTaskLinkEntityNotFound extends KgTaskLinkFailure {
  const KgTaskLinkEntityNotFound(this.entityId);
  final String entityId;
}

final class KgTaskLinkInvalidRefType extends KgTaskLinkFailure {
  const KgTaskLinkInvalidRefType(this.value);
  final String value;
}

final class KgTaskLinkCrossProject extends KgTaskLinkFailure {
  const KgTaskLinkCrossProject({
    required this.taskId,
    required this.entityId,
  });

  final String taskId;
  final String entityId;
}
