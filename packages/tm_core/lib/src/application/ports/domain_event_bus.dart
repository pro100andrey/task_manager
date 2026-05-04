abstract class DomainEventBus {
  void publish(Object event);
  Stream<T> on<T>();
}
