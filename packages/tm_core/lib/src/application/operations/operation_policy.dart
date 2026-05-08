import 'dart:async';

import '../../domain/result.dart';
import 'command.dart';
import 'operation_context.dart';

// Policy is an explicit architectural contract for operation guards.
// ignore: one_member_abstracts
abstract class Policy<C extends Command, F> {
  FutureOr<Iterable<F>> check(C command, OperationContext context);
}

final class PolicySet<C extends Command, F> {
  const PolicySet(this._policies);

  static const empty = PolicySet<Command, dynamic>([]);

  final List<Policy<C, F>> _policies;

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
