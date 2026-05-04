import '../../domain/result.dart';

// Intentional single-method interface: Operation is a named architectural
// contract, not a top-level function.
// ignore: one_member_abstracts
abstract class Operation<C, S, F> {
  Future<Result<S, F>> execute(C command);
}
