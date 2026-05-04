import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../adapters/events/ordered_domain_event_bus_impl.dart';
import '../application/ports/domain_event_bus.dart';
import 'injection.config.dart';

@InjectableInit(
  initializerName: r'$initTmCore',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureTmCoreDependencies({
  String environment = Environment.dev,
  bool useOrderedBus = false,
}) async {
  final getIt = GetIt.instance;

  $initTmCore(getIt, environment: environment);

  if (useOrderedBus) {
    getIt
      ..unregister<DomainEventBus>()
      ..registerSingleton<DomainEventBus>(OrderedDomainEventBusImpl());
  }
}
