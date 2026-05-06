class RecursiveReflectionWarning implements Exception {
  const RecursiveReflectionWarning(this.message);

  final String message;

  @override
  String toString() => 'RecursiveReflectionWarning: $message';
}

class StallDetectedException implements Exception {
  const StallDetectedException(this.message);

  final String message;

  @override
  String toString() => 'StallDetectedException: $message';
}
