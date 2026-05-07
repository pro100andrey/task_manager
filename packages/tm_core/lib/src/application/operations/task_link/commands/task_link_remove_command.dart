import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskLinkRemoveCommand extends Command {
  const TaskLinkRemoveCommand({
    required this.fromTaskId,
    required this.toTaskId,
    this.linkType,
  });

  final TaskId fromTaskId;
  final TaskId toTaskId;

  /// If null, removes all link types between the two tasks.
  final LinkType? linkType;
}
