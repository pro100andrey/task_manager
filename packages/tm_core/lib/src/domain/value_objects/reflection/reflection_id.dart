import 'package:uuid/uuid.dart';

import '../../../tools/uuid.dart';

extension type const ReflectionId(String value) implements String {
  factory ReflectionId.generate() {
    final newUuid = const Uuid().v7();
    return ReflectionId(newUuid);
  }

  String get raw => value;

  String? get formatError {
    if (!isValidUUIDv7(value)) {
      return 'Invalid UUID(v7) format for ReflectionId: $value';
    }
    return null;
  }
}
