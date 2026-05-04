//
// ignore: one_member_abstracts
abstract class TracingPort {
  Future<T> trace<T>(String operationName, Future<T> Function() action);
}
