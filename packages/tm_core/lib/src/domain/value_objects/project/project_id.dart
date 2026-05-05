import 'package:uuid/uuid.dart';
import 'package:uuid/validation.dart';

extension type const ProjectId(String value) {
  /// Factory constructor to generate a new ProjectId with a unique UUID (v7).
  factory ProjectId.generate() {
    // Generate a new UUID for the project.
    final newUuid = const Uuid().v7();

    return ProjectId(newUuid);
  }

  String? get formatError {
    if (!UuidValidation.isValidUUID(fromString: value)) {
      return 'Invalid UUID format for ProjectId: $value';
    }

    return null;
  }
}
