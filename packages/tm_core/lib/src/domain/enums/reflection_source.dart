enum ReflectionSource {
  cli('cli'),
  tui('tui'),
  mcp('mcp'),
  ;

  const ReflectionSource(this.value);

  final String value;

  static ReflectionSource? tryParse(String raw) {
    for (final value in values) {
      if (value.value == raw) {
        return value;
      }
    }
    return null;
  }
}
