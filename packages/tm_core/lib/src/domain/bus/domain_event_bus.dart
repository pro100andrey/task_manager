import '../events/domain_event.dart';

export '../events/domain_event.dart';

//
// ignore: one_member_abstracts
abstract class DomainEventBus {
  void publish(DomainEvent event);
}
