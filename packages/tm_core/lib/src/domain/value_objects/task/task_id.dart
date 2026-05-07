import 'package:uuid/uuid.dart';

import '../../../tools/uuid.dart';

/// A value object representing a task's unique identifier.
extension type const TaskId(String value) {
  /// Factory constructor to generate a new TaskId with a unique UUID (v7).
  factory TaskId.generate() {
    // Generate a new UUID(v7) for the task.
    final newUuid = const Uuid().v7();

    return TaskId(newUuid);
  }

  String? get formatError {
    if (!isValidUUIDv7(value)) {
      return 'Invalid UUID(v7) format for TaskId: $value';
    }

    return null;
  }
}
