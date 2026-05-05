import 'package:logging/logging.dart';

import '../../application/operations/operation_behavior.dart';
import '../../application/operations/operation_context.dart';
import '../../application/ports/tracing_port.dart';
import '../../domain/result.dart';
import '../tracing/tracing_logging_config.dart';

class TracingBehavior implements OperationBehavior {
  const TracingBehavior(this._tracing, {TracingLoggingConfig? config})
    : _config = config ?? const TracingLoggingConfig();

  final TracingPort _tracing;
  final TracingLoggingConfig _config;

  @override
  Future<Result<S, F>> handle<S, F>(
    OperationContext ctx,
    Future<Result<S, F>> Function() next,
  ) async {
    final result = await _tracing.trace(
      ctx.name,
      next,
      attributes: ctx.attributes.isEmpty ? null : ctx.attributes,
    );

    if (result.isFailure) {
      final logger = Logger(_config.loggerName);
      final attrs = ctx.attributes.isEmpty ? '' : ' ${ctx.attributes}';
      logger.log(
        _config.domainFailureLevel,
        '✗ ${ctx.name} returned domain failure$attrs: ${result.error}',
      );
    }

    return result;
  }
}
