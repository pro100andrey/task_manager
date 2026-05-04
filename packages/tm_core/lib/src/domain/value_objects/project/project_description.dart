extension type ProjectDescription._(String value) {
  factory ProjectDescription(String value) {
    if (value case String(isEmpty: true)) {
      throw ArgumentError('ProjectDescription cannot be empty');
    } else if (value case String(length: > 500)) {
      throw ArgumentError('ProjectDescription cannot exceed 500 characters');
    }

    return ProjectDescription._(value);
  }

  String get raw => value;
}
