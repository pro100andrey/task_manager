import 'package:uuid/uuid.dart';

import '../../../tools/uuid.dart';

/// Represents a unique identifier for a Project in the Task Manager
/// application.
extension type const ProjectId(String value) {
  /// Factory constructor to generate a new ProjectId with a unique UUID (v7).
  factory ProjectId.generate() {
    // Generate a new UUID for the project.
    final newUuid = const Uuid().v7();

    return ProjectId(newUuid);
  }

  String? get formatError {
    if (!isValidUUIDv7(value)) {
      return 'Invalid UUID(v7) format for ProjectId: $value';
    }

    return null;
  }
}
