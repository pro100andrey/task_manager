extension type const ProjectDescription(String value) {
  String? get cannotBeEmptyError =>
      value.isEmpty ? 'ProjectDescription cannot be empty' : null;

  String? get cannotExceedMaxLengthError => value.length > 500
      ? 'ProjectDescription cannot exceed 500 characters'
      : null;
}
