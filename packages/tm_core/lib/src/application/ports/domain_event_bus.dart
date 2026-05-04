import 'dart:async';

abstract class DomainEventBus {
  Future<void> publish(Object event);
  Stream<T> on<T>();

  StreamSubscription<T> listen<T>(
    void Function(T event) onEvent, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  Future<void> dispose();
}
