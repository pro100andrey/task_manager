import 'package:uuid/uuid.dart';

import '../../../tools/uuid.dart';

/// UUIDv7 identifier for Knowledge entities.
extension type const KnowledgeEntityId(String value) implements String {
  factory KnowledgeEntityId.generate() {
    final newUuid = const Uuid().v7();
    return KnowledgeEntityId(newUuid);
  }

  String? get formatError {
    if (!isValidUUIDv7(value)) {
      return 'Invalid UUID(v7) format for KnowledgeEntityId: $value';
    }

    return null;
  }
}
