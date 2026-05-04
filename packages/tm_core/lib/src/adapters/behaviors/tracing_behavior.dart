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
  ) => _tracing.trace(
        ctx.name,
        next,
        attributes: ctx.attributes.isEmpty ? null : ctx.attributes,
      );
}
