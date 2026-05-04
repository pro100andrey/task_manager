//
// ignore: one_member_abstracts
abstract class TransactionPort {
  Future<T> run<T>(Future<T> Function() action);
}
