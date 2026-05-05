import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../adapters/events/ordered_domain_event_bus_impl.dart';
import '../adapters/tracing/logging_tracing_port_impl.dart';
import '../adapters/tracing/tracing_logging_config.dart';
import '../application/ports/domain_event_bus.dart';
import '../application/ports/tracing_port.dart';
import 'injection.config.dart';

StreamSubscription<LogRecord>? _tmCoreRootLogSubscription;

@InjectableInit(
  initializerName: r'$initTmCore',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureTmCoreDependencies({
  String environment = Environment.dev,
  bool useOrderedBus = false,
  TracingLoggingConfig? loggingConfig,
}) async {
  $initTmCore(GetIt.I, environment: environment);

  if (loggingConfig != null) {
    if (loggingConfig.rootLevel != null) {
      Logger.root.level = loggingConfig.rootLevel;
    }

    if (loggingConfig.onRecord != null) {
      await _tmCoreRootLogSubscription?.cancel();
      _tmCoreRootLogSubscription = Logger.root.onRecord.listen(
        loggingConfig.onRecord,
      );
    }

    GetIt.I
      ..unregister<TracingPort>()
      ..registerSingleton<TracingPort>(
        LoggingTracingPortImpl(config: loggingConfig),
      );
  }

  if (useOrderedBus) {
    GetIt.I
      ..unregister<DomainEventBus>()
      ..registerSingleton<DomainEventBus>(OrderedDomainEventBusImpl());
  }
}
