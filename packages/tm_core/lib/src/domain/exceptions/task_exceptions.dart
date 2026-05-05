class TaskNotFoundException implements Exception {
  const TaskNotFoundException(this.ref);
  final String ref;

  @override
  String toString() => 'TaskNotFoundException: Task not found for ref "$ref"';
}

class InvalidAliasException implements Exception {
  const InvalidAliasException(this.raw, this.reason);
  final String raw;
  final String reason;

  @override
  String toString() => 'InvalidAliasException: "$raw" — $reason';
}
