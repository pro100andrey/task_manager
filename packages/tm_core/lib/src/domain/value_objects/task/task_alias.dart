extension type TaskAlias._(String value) {
  factory TaskAlias(String value) {
    if (value.isEmpty) {
      throw ArgumentError('TaskAlias cannot be empty');
    }
    final invalid = RegExp(r'[^a-z0-9_\-]');
    if (invalid.hasMatch(value)) {
      throw ArgumentError(
        'TaskAlias must match ^[a-z0-9_-]+\$: "$value"',
      );
    }
    if (value.startsWith('-') || value.endsWith('-')) {
      throw ArgumentError(
        'TaskAlias must not start or end with "-": "$value"',
      );
    }
    return TaskAlias._(value);
  }

  String get raw => value;
}
