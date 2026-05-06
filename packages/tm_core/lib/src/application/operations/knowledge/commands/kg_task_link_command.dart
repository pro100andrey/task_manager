import '../../command.dart';

class KgTaskLinkCommand extends Command {
  const KgTaskLinkCommand({
    required this.taskId,
    required this.entityId,
    required this.refType,
  });

  final String taskId;
  final String entityId;
  final String refType;
}
