import '../../../../domain/value_objects/task/task_id.dart';
import '../../../ports/task_repository.dart';
import '../../command.dart';
import '../../operation_context.dart';
import '../../operation_policy.dart';

class TaskExistsPolicy<C extends Command, F> extends PreconditionPolicy<C, F> {
  TaskExistsPolicy(this._repository, this._taskIdSelector, this._notFound);

  final TaskRepository _repository;
  //
  // ignore: unsafe_variance
  final TaskId Function(C command) _taskIdSelector;
  final F Function(TaskId taskId) _notFound;

  @override
  Future<Iterable<F>> check(C command, OperationContext context) async {
    final rawId = _taskIdSelector(command);
    late final TaskId taskId;
    try {
      taskId = rawId;
    } on FormatException {
      return [_notFound(rawId)];
    }
    final existing = await _repository.getById(taskId);
    if (existing == null) {
      return [_notFound(rawId)];
    }
    return const [];
  }
}
