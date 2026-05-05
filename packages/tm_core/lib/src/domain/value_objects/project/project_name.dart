extension type const ProjectName(String value) {
  String? get cannotBeEmptyError =>
      value.isEmpty ? 'ProjectName cannot be empty' : null;
}
