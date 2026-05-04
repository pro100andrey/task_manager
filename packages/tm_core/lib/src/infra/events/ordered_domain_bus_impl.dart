// lib/src/infrastructure/events/domain_event_bus_impl.dart
import 'dart:async';
import 'dart:collection';

import '../../application/ports/domain_event_bus.dart';

class OrderedDomainEventBusImpl implements DomainEventBus {
  final _eventController = StreamController<Object>.broadcast();

  final _eventQueue = Queue<Object>();
  var _isProcessing = false;

  final _subscriptions = <StreamSubscription>[];

  @override
  void publish(Object event) {
    if (_eventController.isClosed) {
      return;
    }

    _eventQueue.addLast(event);
    unawaited(_processQueue());
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _eventQueue.isEmpty) {
      return;
    }

    _isProcessing = true;

    try {
      while (_eventQueue.isNotEmpty) {
        final event = _eventQueue.removeFirst();
        _eventController.add(event); // гарантированно по порядку
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Stream<T> on<T>() =>
      _eventController.stream.where((event) => event is T).cast<T>();

  /// Удобный метод для подписки
  StreamSubscription<T> listen<T>(
    void Function(T event) onEvent, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = on<T>().listen(
      onEvent,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(sub);
    return sub;
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
