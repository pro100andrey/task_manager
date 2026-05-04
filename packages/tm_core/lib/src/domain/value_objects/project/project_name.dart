extension type ProjectName._(String value) {
  factory ProjectName(String value) {
    if (value case String(isEmpty: true)) {
      throw ArgumentError('ProjectName cannot be empty');
    }

    return ProjectName._(value);
  }

  String get raw => value;
}
