import '../../domain/result.dart';
import 'command.dart';
import 'operation_context.dart';
import 'operation_pipeline.dart';
import 'operation_policy.dart';

abstract class Operation<C extends Command, S, F> {
  Operation(OperationPipeline pipeline) : _pipeline = pipeline;

  final OperationPipeline _pipeline;

  String get operationName;

  Map<String, dynamic> traceAttributes(C command) => const {};

  Future<Result<S, F>> execute(C command) {
    final context = _buildContext(command);

    return _pipeline.run(context, () async {
      final preconditionFailures = await preconditionPolicies(
        command,
        context,
      ).evaluateAll(command, context);

      final preconditionResult = preconditionFailures.toFailureResult<S>();
      if (preconditionResult != null) {
        return mapResult(command, context, preconditionResult);
      }

      final coreResult = await run(command);

      final invariantFailures = await invariantPolicies(
        command,
        context,
        coreResult,
      ).evaluateAll(command, context);

      final invariantResult = invariantFailures.toFailureResult<S>();
      final result = invariantResult ?? coreResult;

      await collectAndPublishEvents(command, context, result);
      return mapResult(command, context, result);
    });
  }

  OperationContext _buildContext(C command) => OperationContext(
    name: operationName,
    attributes: traceAttributes(command),
  );

  PolicySet<C, F> preconditionPolicies(
    C command,
    OperationContext context,
  ) => const .new([]);

  PolicySet<C, F> invariantPolicies(
    C command,
    OperationContext context,
    Result<S, F> result,
  ) => PolicySet<C, F>([]);

  Future<void> collectAndPublishEvents(
    C command,
    OperationContext context,
    Result<S, F> result,
  ) async {}

  Result<S, F> mapResult(
    C command,
    OperationContext context,
    Result<S, F> result,
  ) => result;

  Future<Result<S, F>> run(C command);
}
