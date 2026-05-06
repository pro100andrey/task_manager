import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

/// UUIDv7 identifier for Knowledge entities.
extension type const KnowledgeEntityId._(String value) implements String {
  factory KnowledgeEntityId(String value) {
    if (!UuidValidation.isValidUUID(fromString: value) || !_isUuidV7(value)) {
      throw FormatException(
        'Invalid UUID format for KnowledgeEntityId: $value',
      );
    }

    return KnowledgeEntityId._(value);
  }

  factory KnowledgeEntityId.generate() {
    final newUuid = const Uuid().v7();
    return KnowledgeEntityId(newUuid);
  }

  String get raw => value;

  static bool _isUuidV7(String value) => value.length >= 15 && value[14] == '7';
}
