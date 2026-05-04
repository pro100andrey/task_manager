// lib/src/infrastructure/events/domain_event_bus_impl.dart
import 'dart:async';

import '../../application/ports/domain_event_bus.dart';

class DomainEventBusImpl implements DomainEventBus {
  final _eventController = StreamController<Object>.broadcast();
  final _subscriptions = <StreamSubscription>[];

  @override
  void publish(Object event) {
    if (_eventController.isClosed) {
      return;
    }
    _eventController.add(event);
  }

  @override
  Stream<T> on<T>() =>
      _eventController.stream.where((event) => event is T).cast<T>();

  /// Подписка с автоматической отпиской (удобно для UI/TUI)
  StreamSubscription<T> listen<T>(void Function(T event) onEvent) {
    final subscription = on<T>().listen(onEvent);
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
