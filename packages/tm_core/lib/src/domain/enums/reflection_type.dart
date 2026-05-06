enum ReflectionType {
  observation('observation'),
  decision('decision'),
  blocker('blocker'),
  insight('insight'),
  replanTrigger('replan_trigger'),
  ;

  const ReflectionType(this.value);

  final String value;

  static ReflectionType? tryParse(String raw) {
    for (final value in values) {
      if (value.value == raw) {
        return value;
      }
    }
    return null;
  }
}
