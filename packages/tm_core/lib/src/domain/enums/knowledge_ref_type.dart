enum KnowledgeRefType {
  produces('produces'),
  consumes('consumes'),
  updates('updates'),
  blocks('blocks')
  ;

  const KnowledgeRefType(this.value);
  final String value;

  bool get isProduces => this == KnowledgeRefType.produces;
  bool get isConsumes => this == KnowledgeRefType.consumes;

  static KnowledgeRefType? tryParse(String value) =>
      KnowledgeRefType.values.where((t) => t.value == value).firstOrNull;
}
