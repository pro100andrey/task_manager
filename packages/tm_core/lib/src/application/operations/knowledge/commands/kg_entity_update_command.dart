import '../../command.dart';

class KgEntityUpdateCommand extends Command {
  const KgEntityUpdateCommand({
    required this.entityId,
    this.content,
    this.entityType,
    this.metadata,
    this.clearMetadata = false,
  });

  final String entityId;
  final String? content;
  final String? entityType;
  final Map<String, dynamic>? metadata;
  final bool clearMetadata;
}
