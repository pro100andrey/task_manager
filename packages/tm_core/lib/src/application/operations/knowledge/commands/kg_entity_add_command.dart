import '../../../../../tm_core.dart';
import '../../command.dart';

class KgEntityAddCommand extends Command {
  const KgEntityAddCommand({
    required this.projectId,
    required this.name,
    required this.entityType,
    required this.content,
    this.metadata = const {},
  });

  final ProjectId projectId;
  final String name;
  final String entityType;
  final String content;
  final Map<String, dynamic> metadata;
}
