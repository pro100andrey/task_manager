extension type TaskTitle._(String value) {
  factory TaskTitle(String value) {
    if (value.isEmpty) {
      throw ArgumentError('TaskTitle cannot be empty');
    }

    return TaskTitle._(value);
  }
}
