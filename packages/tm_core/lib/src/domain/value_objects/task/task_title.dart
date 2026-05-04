/// A value object representing the title of a task.
extension type TaskTitle._(String value) {
  factory TaskTitle(String value) {
    if (value case String(isEmpty: true)) {
      throw ArgumentError('TaskTitle cannot be empty');
    }

    return TaskTitle._(value);
  }
}
