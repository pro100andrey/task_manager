import '../../../../../tm_core.dart';
import '../../command.dart';

class KgTaskLinkCommand extends Command {
  const KgTaskLinkCommand({
    required this.taskId,
    required this.entityId,
    required this.refType,
  });

  final TaskId taskId;
  final KnowledgeEntityId entityId;
  final String refType;
}
