enum LinkType {
  strong('strong'),
  soft('soft'),
  unknown('unknown')
  ;

  const LinkType(this.value);
  final String value;

  static LinkType fromValue(String value) => LinkType.values.firstWhere(
    (lt) => lt.value == value,
    orElse: () => LinkType.unknown,
  );
}
