// lib/src/adapters/events/ordered_domain_event_bus_impl.dart
import 'dart:async';
import 'dart:collection';

import '../../events/event_bus.dart';

class OrderedDomainEventBusImpl implements EventBus {
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
    _processQueue();
  }

  void _processQueue() {
    if (_isProcessing || _eventQueue.isEmpty) {
      return;
    }

    _isProcessing = true;

    try {
      while (_eventQueue.isNotEmpty) {
        final event = _eventQueue.removeFirst();
        // Guarantee that events are published in the order they were added to
        // the queue
        _eventController.add(event);
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Stream<T> on<T>() =>
      _eventController.stream.where((event) => event is T).cast<T>();

  /// Convenient method for subscribing to events of type [T].
  @override
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
