/// A value object representing the description of a task.
extension type TaskDescription._(String value) {
  factory TaskDescription(String value) {
    if (value.isEmpty) {
      throw ArgumentError('TaskDescription cannot be empty');
    }

    return TaskDescription._(value);
  }
}
