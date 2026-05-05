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
    final result = await _tracing.trace(
      ctx.name,
      next,
      attributes: ctx.attributes.isEmpty ? null : ctx.attributes,
    );

    if (result case Failure<S, F>(:final error)) {
      _tracing.logDomainFailure(
        ctx.name,
        error as Object,
        attributes: ctx.attributes.isEmpty ? null : ctx.attributes,
      );
    }

    return result;
  }
}
