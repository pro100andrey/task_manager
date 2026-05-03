/// A value object representing a task's unique identifier.
extension type TaskId._(String value) {
  factory TaskId(String value) {
    if (value.isEmpty) {
      throw ArgumentError('TaskId cannot be empty');
    }

    return TaskId._(value);
  }
}
