class CycleException implements Exception {
  const CycleException(this.path);

  /// The detected cycle path as a list of task IDs.
  final List<String> path;

  @override
  String toString() => 'CycleException: cycle detected → ${path.join(' → ')}';
}
