import '../../../domain/entities/reflection.dart';
import '../../../domain/enums/reflection_type.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/project_repository.dart';
import '../../ports/reflection_repository.dart';
import '../../ports/task_repository.dart';

class ReflectionListParams {
  const ReflectionListParams({
    this.taskId,
    this.reflectionType,
    this.since,
  });

  final TaskId? taskId;
  final String? reflectionType;
  final String? since;
}

class ReflectionListQuery {
  ReflectionListQuery(
    this._projectRepository,
    this._taskRepository,
    this._reflectionRepository,
  );

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final ReflectionRepository _reflectionRepository;

  Future<List<Reflection>> execute(ReflectionListParams params) async {
    final reflections = await _loadReflections(params.taskId);
    if (reflections.isEmpty) {
      return const [];
    }

    final filterType = params.reflectionType != null
        ? ReflectionType.tryParse(params.reflectionType!)
        : null;
    if (params.reflectionType != null && filterType == null) {
      return const [];
    }

    final since = params.since != null
        ? DateTime.tryParse(params.since!)
        : null;

    final filtered = reflections.where((reflection) {
      if (filterType != null && reflection.reflectionType != filterType) {
        return false;
      }
      if (since != null && reflection.createdAt.isBefore(since)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  Future<List<Reflection>> _loadReflections(TaskId? taskId) async {
    if (taskId != null) {
      late final TaskId id;
      try {
        id = taskId;
      } on FormatException {
        return const [];
      }

      final task = await _taskRepository.getById(id);
      if (task == null) {
        return const [];
      }

      return _reflectionRepository.getByTaskId(id);
    }

    final currentProject = await _projectRepository.getCurrentProject();
    if (currentProject == null) {
      return const [];
    }

    return _reflectionRepository.getByProjectId(currentProject.id);
  }
}
