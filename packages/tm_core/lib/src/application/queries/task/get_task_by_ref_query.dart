import '../../../domain/entities/task.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../../domain/value_objects/task/task_ref.dart';
import '../../ports/task_repository.dart';

class GetTaskByRefParams {
  const GetTaskByRefParams({
    required this.projectId,
    required this.ref,
  });

  /// Raw project ID string.
  final ProjectId projectId;

  /// UUID v7 or alias string (§7).
  final TaskRef ref;
}

/// Resolves a task reference (UUID v7 or alias) to a [Task] per §7.
///
/// Resolution order:
/// 1. If `ref` looks like a UUIDv7 → look up by id.
/// 2. Otherwise → normalize as alias → look up by normalizedAlias.
/// 3. If not found → returns null.
class GetTaskByRefQuery {
  GetTaskByRefQuery(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<Task?> execute(GetTaskByRefParams params) async {
    if (params.projectId.formatError case final _?) {
      return null;
    }

    // Try UUID first

    switch (params.ref) {
      case TaskIdRef(:final id):
        return _taskRepository.getById(id);
      case TaskAliasRef(:final alias):
        return _taskRepository.getByAlias(params.projectId, alias);
    }
  }
}
