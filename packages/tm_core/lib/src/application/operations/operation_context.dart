class OperationContext {
  const OperationContext({
    required this.name,
    this.attributes = const {},
  });

  final String name;
  final Map<String, dynamic> attributes;
}
