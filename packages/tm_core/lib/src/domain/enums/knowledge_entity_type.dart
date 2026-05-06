enum KnowledgeEntityType {
  fact('fact'),
  decision('decision'),
  assumption('assumption'),
  risk('risk'),
  resource('resource'),
  concept('concept'),
  tool('tool')
  ;

  const KnowledgeEntityType(this.value);
  final String value;

  static KnowledgeEntityType? tryParse(String value) =>
      KnowledgeEntityType.values.where((t) => t.value == value).firstOrNull;
}
