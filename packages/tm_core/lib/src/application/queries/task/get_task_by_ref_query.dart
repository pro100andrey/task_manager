import '../../../domain/entities/task.dart';
import '../../../domain/exceptions/task_exceptions.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/project/project_id.dart';
import '../../../domain/value_objects/task/task_alias.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/task_repository.dart';

class GetTaskByRefParams {
  const GetTaskByRefParams({
    required this.projectId,
    required this.ref,
  });

  /// Raw project ID string.
  final String projectId;

  /// UUID v7 or alias string (§7).
  final String ref;
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
    late final ProjectId projectId;
    try {
      projectId = ProjectId(params.projectId);
    } on FormatException {
      return null;
    }

    // Try UUID first
    try {
      final id = TaskId(params.ref);
      return await _taskRepository.getById(id);
    } on FormatException {
      // Not a UUIDv7 — fall through to alias lookup
    }

    // Normalize as alias and search
    try {
      final normalized = normalizeAlias(params.ref);
      final alias = TaskAlias(normalized);
      return await _taskRepository.getByAlias(projectId, alias);
    } on InvalidAliasException {
      return null;
    }
  }
}
