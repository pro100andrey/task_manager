import '../../../../../tm_core.dart';

sealed class TaskLinkRemoveFailure {
  const TaskLinkRemoveFailure();
}

final class TaskLinkRemoveNotFound extends TaskLinkRemoveFailure {
  const TaskLinkRemoveNotFound({
    required this.fromTaskId,
    required this.toTaskId,
    this.linkType,
  });
  final TaskId fromTaskId;
  final TaskId toTaskId;
  final LinkType? linkType;
}

final class TaskLinkRemoveInvalidLinkType extends TaskLinkRemoveFailure {
  const TaskLinkRemoveInvalidLinkType(this.value);
  final LinkType value;
}
