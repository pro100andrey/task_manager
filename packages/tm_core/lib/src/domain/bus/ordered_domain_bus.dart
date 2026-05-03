import 'dart:async';

import 'domain_event_bus.dart';

final class OrderedDomainBus implements DomainEventBus {
  final Map<Type, EventQueue> _queues = {};
  final _globalOrder = StreamController<DomainEvent>.broadcast(sync: true);

  @override
  void publish(DomainEvent event) {
    _globalOrder.add(event);



    _queues.putIfAbsent(event.runtimeType, EventQueue.new).add(event);
  }
}

final class EventQueue {
  final _controller = StreamController<DomainEvent>(sync: true);

  void add(DomainEvent event) {
    _controller.add(event);
  }

  Stream<DomainEvent> get stream => _controller.stream;
}
