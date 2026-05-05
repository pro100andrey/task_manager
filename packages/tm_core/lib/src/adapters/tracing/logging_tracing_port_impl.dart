// lib/src/adapters/tracing/logging_tracing_port_impl.dart
import 'package:logging/logging.dart';

import '../../application/ports/tracing_port.dart';
import 'tracing_logging_config.dart';

class LoggingTracingPortImpl implements TracingPort {
  LoggingTracingPortImpl({TracingLoggingConfig? config})
    : _config = config ?? const TracingLoggingConfig(),
      _logger = Logger((config ?? const TracingLoggingConfig()).loggerName);

  final TracingLoggingConfig _config;
  final Logger _logger;

  @override
  Future<T> trace<T>(
    String operationName,
    Future<T> Function() action, {
    Map<String, dynamic>? attributes,
  }) async {
    if (!_config.enabled) {
      return action();
    }

    final stopwatch = Stopwatch()..start();

    final startMessage = '→ $operationName started';
    if (attributes != null && attributes.isNotEmpty) {
      _logger.log(_config.startLevel, '$startMessage $attributes');
    } else {
      _logger.log(_config.startLevel, startMessage);
    }

    try {
      final result = await action();
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;
      _logger.log(
        _config.successLevel,
        '✓ $operationName completed in ${duration}ms',
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      _logger.log(
        _config.errorLevel,
        '✗ $operationName failed after ${duration}ms',
        error,
        _config.includeStackTrace ? stackTrace : null,
      );

      if (_config.logAttributesOnError &&
          attributes != null &&
          attributes.isNotEmpty) {
        _logger.severe('  Attributes: $attributes');
      }

      rethrow;
    }
  }

  @override
  void logDomainFailure(
    String operationName,
    Object error, {
    Map<String, dynamic>? attributes,
  }) {
    if (!_config.enabled) {
      return;
    }

    final attrs = attributes == null || attributes.isEmpty
        ? ''
        : ' $attributes';
    _logger.log(
      _config.domainFailureLevel,
      '✗ $operationName returned domain failure$attrs: $error',
    );
  }

  @override
  T traceSync<T>(
    String operationName,
    T Function() action, {
    Map<String, dynamic>? attributes,
  }) {
    if (!_config.enabled) {
      return action();
    }

    final stopwatch = Stopwatch()..start();

    final startMessage = '→ $operationName started (sync)';
    if (attributes != null && attributes.isNotEmpty) {
      _logger.log(_config.startLevel, '$startMessage $attributes');
    } else {
      _logger.log(_config.startLevel, startMessage);
    }

    try {
      final result = action();
      stopwatch.stop();
      _logger.log(
        _config.successLevel,
        '✓ $operationName completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logger.log(
        _config.errorLevel,
        '✗ $operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        error,
        _config.includeStackTrace ? stackTrace : null,
      );
      rethrow;
    }
  }
}
