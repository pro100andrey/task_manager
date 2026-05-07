import '../../../tm_core.dart';

class CycleException implements Exception {
  const CycleException(this.path);

  /// The detected cycle path as a list of task IDs.
  final List<TaskId> path;

  @override
  String toString() => 'CycleException: cycle detected → ${path.join(' → ')}';
}
