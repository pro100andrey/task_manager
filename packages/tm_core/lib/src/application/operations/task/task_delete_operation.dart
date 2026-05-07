import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_delete_command.dart';
import 'failures/task_delete_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskDeleteCommand, void, TaskDeleteFailure>;

class TaskDeleteOperation extends _Operation {
  TaskDeleteOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskDeleteOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskDeleteCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskDeleteCommand, TaskDeleteFailure> preconditionPolicies(
    TaskDeleteCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskDeleteCommand, TaskDeleteFailure>(
      _repository,
      (cmd) => cmd.taskId,
      TaskDeleteNotFound.new,
    ),
  ]);

  @override
  Future<Result<void, TaskDeleteFailure>> run(
    TaskDeleteCommand command,
  ) async {
    final id = command.taskId;
    await _repository.delete(id);
    await _bus.publish(TaskDeletedEvent(taskId: id));
    return const Success(null);
  }
}
