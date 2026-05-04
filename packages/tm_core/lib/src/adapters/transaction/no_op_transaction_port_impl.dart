import '../../application/ports/transaction_port.dart';

class NoOpTransactionPortImpl implements TransactionPort {
  @override
  Future<T> run<T>(Future<T> Function() action) => action();
}
