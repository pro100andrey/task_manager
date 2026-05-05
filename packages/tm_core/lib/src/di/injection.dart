import 'dart:async';

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
  $initTmCore(GetIt.I, environment: environment);

  //  if (GetIt.I.rootLevel != null) {
  //   Logger.root.level = loggingConfig.rootLevel;
  // }


  if (useOrderedBus) {
    GetIt.I
      ..unregister<DomainEventBus>()
      ..registerSingleton<DomainEventBus>(OrderedDomainEventBusImpl());
  }
}
