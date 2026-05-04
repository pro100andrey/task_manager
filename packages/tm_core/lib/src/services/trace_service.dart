class TraceService {
  Future<T> trace<T>(
    String operation,
    Future<T> Function() body, {
    Map<String, dynamic>? metadata,
    bool sample = true,
  }) => body();
}
