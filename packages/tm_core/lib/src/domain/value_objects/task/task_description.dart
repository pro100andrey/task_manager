/// A value object representing the description of a task.
extension type TaskDescription._(String value) {
  factory TaskDescription(String value) {
    if (value case String(isEmpty: true)) {
      throw ArgumentError('TaskDescription cannot be empty');
    } else if (value case String(length: > 500)) {
      throw ArgumentError('TaskDescription cannot exceed 500 characters');
    }

    return TaskDescription._(value);
  }

  String get raw => value;
}
