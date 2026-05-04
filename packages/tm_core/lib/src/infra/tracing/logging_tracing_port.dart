// lib/src/infrastructure/tracing/logging_tracing_port.dart
import 'package:logging/logging.dart';

import '../../application/ports/tracing_port.dart';

class LoggingTracingPortImpl implements TracingPort {
  static final _logger = Logger('TM.Core');

  @override
  Future<T> trace<T>(
    String operationName,
    Future<T> Function() action, {
    Map<String, dynamic>? attributes,
    Level level = Level.INFO,
  }) async {
    final stopwatch = Stopwatch()..start();

    final startMessage = '→ $operationName started';
    if (attributes != null && attributes.isNotEmpty) {
      _logger.log(level, '$startMessage $attributes');
    } else {
      _logger.log(level, startMessage);
    }

    try {
      final result = await action();
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;
      _logger.fine('✓ $operationName completed in ${duration}ms');
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      _logger.log(
        Level.SEVERE,
        '✗ $operationName failed after ${duration}ms',
        error,
        stackTrace,
      );

      if (attributes != null && attributes.isNotEmpty) {
        _logger.severe('  Attributes: $attributes');
      }

      rethrow;
    }
  }

  @override
  T traceSync<T>(
    String operationName,
    T Function() action, {
    Map<String, dynamic>? attributes,
    Level level = Level.INFO,
  }) {
    final stopwatch = Stopwatch()..start();

    final startMessage = '→ $operationName started (sync)';
    if (attributes != null && attributes.isNotEmpty) {
      _logger.log(level, '$startMessage $attributes');
    } else {
      _logger.log(level, startMessage);
    }

    try {
      final result = action();
      stopwatch.stop();
      _logger.fine(
        '✓ $operationName completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logger.log(
        Level.SEVERE,
        '✗ $operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
