import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';

class LinkListParams {
  const LinkListParams({
    required this.taskId,
    this.direction = 'both',
    this.linkType,
  });

  /// Raw UUID of the task.
  final TaskId taskId;

  /// 'from' | 'to' | 'both' (default 'both').
  final String direction;

  /// 'strong' | 'soft'. Null means all link types.
  final LinkType? linkType;
}

class LinkListItem {
  const LinkListItem({required this.link, required this.task});

  /// The link itself.
  final TaskLink link;

  /// The task on the other end of the link.
  final Task task;
}

/// Returns links for a task per §11.8, including the Task on the other end.
class LinkListQuery {
  LinkListQuery(this._linkRepository, this._taskRepository);

  final TaskLinkRepository _linkRepository;
  final TaskRepository _taskRepository;

  Future<List<LinkListItem>> execute(LinkListParams params) async {
    late final TaskId taskId;
    try {
      taskId = params.taskId;
    } on FormatException {
      return const [];
    }

    // Validate direction
    if (!{'from', 'to', 'both'}.contains(params.direction)) {
      return const [];
    }

    // Optional link type filter
    LinkType? typeFilter;
    if (params.linkType != null) {
      typeFilter = LinkType.values
          .where((e) => e == params.linkType)
          .firstOrNull;
      if (typeFilter == null) {
        return const [];
      }
    }

    final links = await _linkRepository.getByTaskId(taskId);

    final result = <LinkListItem>[];
    for (final link in links) {
      // Direction filter
      final isFrom = link.fromTaskId == taskId;
      final isTo = link.toTaskId == taskId;
      final directionMatch = switch (params.direction) {
        'from' => isFrom,
        'to' => isTo,
        _ => isFrom || isTo,
      };
      if (!directionMatch) {
        continue;
      }

      // Link type filter
      if (typeFilter != null && link.linkType != typeFilter) {
        continue;
      }

      // Resolve the other task
      final otherId = isFrom ? link.toTaskId : link.fromTaskId;
      final task = await _taskRepository.getById(otherId);
      if (task == null) {
        continue;
      }

      result.add(LinkListItem(link: link, task: task));
    }

    return result;
  }
}
