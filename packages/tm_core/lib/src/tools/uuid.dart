import 'package:uuid/uuid.dart';

/// Utility function to check if a UUID is version 7.
bool isValidUUIDv7(String uuid) =>
    Uuid.isValidUUID(fromString: uuid) && Uuid.parse(uuid)[6] >> 4 == 7;
