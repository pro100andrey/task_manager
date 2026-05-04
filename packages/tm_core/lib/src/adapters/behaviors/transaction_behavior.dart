import '../../application/operations/operation_behavior.dart';
import '../../application/operations/operation_context.dart';
import '../../application/ports/transaction_port.dart';
import '../../domain/result.dart';

class TransactionBehavior implements OperationBehavior {
  const TransactionBehavior(this._transaction);

  final TransactionPort _transaction;

  @override
  Future<Result<S, F>> handle<S, F>(
    OperationContext ctx,
    Future<Result<S, F>> Function() next,
  ) => _transaction.run(next);
}
