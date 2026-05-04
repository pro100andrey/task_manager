import 'package:logging/logging.dart';

class TracingLoggingConfig {
  const TracingLoggingConfig({
    this.enabled = true,
    this.loggerName = 'TM.Core',
    this.startLevel = Level.INFO,
    this.successLevel = Level.FINE,
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
  final Level errorLevel;
  final bool includeStackTrace;
  final bool logAttributesOnError;

  /// Optional root logger level. When omitted, current root level is preserved.
  final Level? rootLevel;

  /// Optional sink to observe log records (console, file, telemetry, etc).
  final void Function(LogRecord record)? onRecord;
}
