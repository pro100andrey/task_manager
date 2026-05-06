import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

extension type const TaskHistoryId._(String value) implements String {
  factory TaskHistoryId(String value) {
    if (!UuidValidation.isValidUUID(fromString: value) || !_isUuidV7(value)) {
      throw FormatException(
        'Invalid UUID v7 format for TaskHistoryId: $value',
      );
    }
    return TaskHistoryId._(value);
  }

  factory TaskHistoryId.generate() => TaskHistoryId(const Uuid().v7());

  String get raw => value;

  static bool _isUuidV7(String value) => value.length >= 15 && value[14] == '7';
}
