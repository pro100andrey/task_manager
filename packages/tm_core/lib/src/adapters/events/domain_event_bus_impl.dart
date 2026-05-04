// lib/src/adapters/events/domain_event_bus_impl.dart
import 'dart:async';

import '../../application/ports/domain_event_bus.dart';

class DomainEventBusImpl implements DomainEventBus {
  final _eventController = StreamController<Object>.broadcast();
  final _subscriptions = <StreamSubscription>[];

  @override
  Future<void> publish(Object event) async {
    if (_eventController.isClosed) {
      return;
    }
    _eventController.add(event);
  }

  @override
  Stream<T> on<T>() =>
      _eventController.stream.where((event) => event is T).cast<T>();

  /// Подписка с автоматической отпиской (удобно для UI/TUI)
  @override
  StreamSubscription<T> listen<T>(
    void Function(T event) onEvent, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = on<T>().listen(
      onEvent,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  @override
  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _eventController.close();
  }
}
