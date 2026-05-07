import '../../application/operations/operation_behavior.dart';
import '../../application/operations/operation_context.dart';
import '../../application/ports/tracing_port.dart';
import '../../domain/result.dart';

class TracingBehavior implements OperationBehavior {
  const TracingBehavior(this._tracing);

  final TracingPort _tracing;

  @override
  Future<Result<S, F>> handle<S, F>(
    OperationContext ctx,
    Future<Result<S, F>> Function() next,
  ) async {
    final attributes = ctx.attributes.isEmpty ? null : ctx.attributes;
    final result = await _tracing.trace(ctx.name, next, attributes: attributes);

    if (result case Failure<S, F>(:final error)) {
      final err = error as Object;
      _tracing.logDomainFailure(ctx.name, err, attributes: attributes);
    }

    return result;
  }
}
