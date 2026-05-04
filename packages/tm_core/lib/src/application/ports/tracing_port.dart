//
abstract class TracingPort {
  Future<T> trace<T>(
    String operationName,
    Future<T> Function() action, {
    Map<String, dynamic>? attributes,
  });

  T traceSync<T>(
    String operationName,
    T Function() action, {
    Map<String, dynamic>? attributes,
  });
}
