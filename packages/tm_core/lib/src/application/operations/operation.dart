import '../../domain/result.dart';
import 'operation_context.dart';
import 'operation_pipeline.dart';

abstract class Operation<C, S, F> {
  Operation(OperationPipeline pipeline) : _pipeline = pipeline;

  final OperationPipeline _pipeline;

  String get operationName;

  Map<String, dynamic> traceAttributes(C command) => const {};

  Future<Result<S, F>> execute(C command) => _pipeline.run(
    OperationContext(
      name: operationName,
      attributes: traceAttributes(command),
    ),
    () => handle(command),
  );

  Future<Result<S, F>> handle(C command);
}
