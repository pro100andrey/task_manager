import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

extension type const ReflectionId._(String value) implements String {
  factory ReflectionId(String value) {
    if (!UuidValidation.isValidUUID(fromString: value) || !_isUuidV7(value)) {
      throw FormatException('Invalid UUID format for ReflectionId: $value');
    }

    return ReflectionId._(value);
  }

  factory ReflectionId.generate() {
    final newUuid = const Uuid().v7();
    return ReflectionId(newUuid);
  }

  String get raw => value;

  static bool _isUuidV7(String value) => value.length >= 15 && value[14] == '7';
}
