import '../../domain/result.dart';
import 'operation_context.dart';

// OperationBehavior is an extensible named architectural contract —
// new cross-cutting behaviors (audit, retry, idempotency) will be added later.
// ignore: one_member_abstracts
abstract class OperationBehavior {
  Future<Result<S, F>> handle<S, F>(
    OperationContext ctx,
    Future<Result<S, F>> Function() next,
  );
}
