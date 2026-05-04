import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

/// A value object representing a task's unique identifier.
extension type const TaskId._(String value) implements String {
  factory TaskId(String value) {

    if (!UuidValidation.isValidUUID(fromString: value)) {
      throw FormatException('Invalid UUID format for TaskId: $value');
    }

    return TaskId._(value);
  }

  /// Factory constructor to generate a new TaskId with a unique UUID (v7).
  factory TaskId.generate() {
    // Generate a new UUID for the task.
    final newUuid = const Uuid().v7();

    return TaskId(newUuid);
  }

  String get raw => value;
}
