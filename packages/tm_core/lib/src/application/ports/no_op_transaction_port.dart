import 'transaction_port.dart';

class NoOpTransactionPort implements TransactionPort {
  @override
  Future<T> run<T>(Future<T> Function() action) => action();
}
