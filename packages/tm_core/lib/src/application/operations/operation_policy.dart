import '../../domain/result.dart';
import 'operation_context.dart';

// OperationPolicy is an explicit architectural contract for operation guards.
// ignore: one_member_abstracts
abstract class OperationPolicy<C, F> {
  Future<Iterable<F>> check(C command, OperationContext context);
}

abstract class PreconditionPolicy<C, F> extends OperationPolicy<C, F> {}

abstract class InvariantPolicy<C, F> extends OperationPolicy<C, F> {}

class OperationPolicySet<C, F> {
  const OperationPolicySet(this._policies);

  final List<OperationPolicy<C, F>> _policies;

  static const empty = OperationPolicySet<dynamic, dynamic>([]);

  Future<List<F>> evaluateAll(C command, OperationContext context) async {
    final failures = <F>[];

    for (final policy in _policies) {
      final result = await policy.check(command, context);
      failures.addAll(result);
    }

    return failures;
  }
}

extension PolicyFailureResult<F> on List<F> {
  Result<S, F>? toFailureResult<S>() {
    if (isEmpty) {
      return null;
    }

    return Failure(first);
  }
}
