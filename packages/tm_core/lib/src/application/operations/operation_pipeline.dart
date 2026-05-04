import '../../domain/result.dart';
import 'operation_behavior.dart';
import 'operation_context.dart';

class OperationPipeline {
  const OperationPipeline(this._behaviors);

  final List<OperationBehavior> _behaviors;

  Future<Result<S, F>> run<S, F>(
    OperationContext ctx,
    Future<Result<S, F>> Function() action,
  ) {
    var next = action;
    
    for (final behavior in _behaviors.reversed) {
      final b = behavior;
      final n = next;

      next = () => b.handle(ctx, n);
    }

    return next();
  }
}
