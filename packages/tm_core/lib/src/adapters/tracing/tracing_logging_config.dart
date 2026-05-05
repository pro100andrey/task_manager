import 'package:logging/logging.dart';

import '../../../tm_core.dart' show Failure;
import '../../domain/result.dart' show Failure;

class TracingLoggingConfig {
  const TracingLoggingConfig({
    this.enabled = true,
    this.loggerName = 'TM.Core',
    this.startLevel = Level.INFO,
    this.successLevel = Level.FINE,
    this.domainFailureLevel = Level.WARNING,
    this.errorLevel = Level.SEVERE,
    this.includeStackTrace = true,
    this.logAttributesOnError = true,
    this.rootLevel,
    this.onRecord,
  });

  final bool enabled;
  final String loggerName;
  final Level startLevel;
  final Level successLevel;

  /// Log level used when an operation returns a domain [Failure] result
  /// (as opposed to an unhandled exception).
  final Level domainFailureLevel;
  final Level errorLevel;
  final bool includeStackTrace;
  final bool logAttributesOnError;

  /// Optional root logger level. When omitted, current root level is preserved.
  final Level? rootLevel;

  /// Optional sink to observe log records (console, file, telemetry, etc).
  final void Function(LogRecord record)? onRecord;
}
