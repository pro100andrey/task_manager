enum LinkType {
  strong('strong'),
  soft('soft')
  ;

  const LinkType(this.value);
  final String value;

  bool get isStrong => this == LinkType.strong;
}
