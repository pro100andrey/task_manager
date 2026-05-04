import 'dart:async';

import 'package:test/test.dart';
import 'package:tm_core/src/application/ports/domain_event_bus.dart';
import 'package:tm_core/src/infra/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/infra/events/ordered_domain_bus_impl.dart';

class _FooEvent {
  const _FooEvent(this.value);
  final int value;
}

class _BarEvent {
  const _BarEvent(this.label);
  final String label;
}

void _runSharedTests(String name, DomainEventBus Function() factory) {
  group(name, () {
    late DomainEventBus bus;

    setUp(() => bus = factory());
    tearDown(() => bus.dispose());

    test('listener receives published event', () async {
      final received = <_FooEvent>[];
      bus.listen<_FooEvent>(received.add);

      await bus.publish(const _FooEvent(1));
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first.value, 1);
    });

    test('on<T> stream emits only matching type', () async {
      final foos = <_FooEvent>[];
      final bars = <_BarEvent>[];
      bus
        ..listen<_FooEvent>(foos.add)
        ..listen<_BarEvent>(bars.add);

      await bus.publish(const _FooEvent(42));
      await bus.publish(const _BarEvent('hello'));
      await Future<void>.delayed(Duration.zero);

      expect(foos, hasLength(1));
      expect(bars, hasLength(1));
    });

    test('multiple events are received in order', () async {
      final received = <int>[];
      bus.listen<_FooEvent>((e) => received.add(e.value));

      await bus.publish(const _FooEvent(1));
      await bus.publish(const _FooEvent(2));
      await bus.publish(const _FooEvent(3));
      await Future<void>.delayed(Duration.zero);

      expect(received, [1, 2, 3]);
    });

    test('publish after dispose is a no-op', () async {
      await bus.dispose();
      await expectLater(bus.publish(const _FooEvent(0)), completes);
    });
  });
}

void main() {
  _runSharedTests('DomainEventBusImpl', DomainEventBusImpl.new);
  _runSharedTests('OrderedDomainEventBusImpl', OrderedDomainEventBusImpl.new);
}
