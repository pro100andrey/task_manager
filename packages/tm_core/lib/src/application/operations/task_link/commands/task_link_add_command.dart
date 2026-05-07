import '../../../../../tm_core.dart';
import '../../command.dart';

class TaskLinkAddCommand extends Command {
  const TaskLinkAddCommand({
    required this.fromTaskId,
    required this.toTaskId,
    required this.linkType,
    this.label,
  });

  final TaskId fromTaskId;
  final TaskId toTaskId;
  final LinkType linkType;
  final String? label;
}
