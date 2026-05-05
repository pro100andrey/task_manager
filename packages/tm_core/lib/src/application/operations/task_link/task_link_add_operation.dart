import 'package:uuid/uuid.dart';

import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/cycle_exception.dart';
import '../../../domain/result.dart';
import '../../../domain/services/task_graph.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_link_add_command.dart';
import 'failures/task_link_add_failure.dart';

typedef _Operation =
    Operation<TaskLinkAddCommand, TaskLink, TaskLinkAddFailure>;

class TaskLinkAddOperation extends _Operation {
  TaskLinkAddOperation(
    super.pipeline,
    this._taskRepository,
    this._linkRepository,
    this._bus,
  );

  final TaskRepository _taskRepository;
  final TaskLinkRepository _linkRepository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskLinkAddOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskLinkAddCommand command) => {
    'fromTaskId': command.fromTaskId,
    'toTaskId': command.toTaskId,
    'linkType': command.linkType,
  };

  @override
  OperationPolicySet<TaskLinkAddCommand, TaskLinkAddFailure>
  preconditionPolicies(
    TaskLinkAddCommand command,
    OperationContext context,
  ) => const OperationPolicySet([]);

  @override
  Future<Result<TaskLink, TaskLinkAddFailure>> run(
    TaskLinkAddCommand command,
  ) async {
    // Validate fromTaskId
    late final TaskId fromId;
    try {
      fromId = TaskId(command.fromTaskId);
    } on FormatException {
      return Failure(TaskLinkAddFromNotFound(command.fromTaskId));
    }

    // Validate toTaskId
    late final TaskId toId;
    try {
      toId = TaskId(command.toTaskId);
    } on FormatException {
      return Failure(TaskLinkAddToNotFound(command.toTaskId));
    }

    // Self-reference guard
    if (fromId == toId) {
      return Failure(TaskLinkAddSelfReference(command.fromTaskId));
    }

    // Parse link type
    final linkType = LinkType.values
        .where((lt) => lt.value == command.linkType)
        .firstOrNull;
    if (linkType == null) {
      return Failure(TaskLinkAddInvalidLinkType(command.linkType));
    }

    // Ensure both tasks exist
    final fromTask = await _taskRepository.getById(fromId);
    if (fromTask == null) {
      return Failure(TaskLinkAddFromNotFound(command.fromTaskId));
    }
    
    final toTask = await _taskRepository.getById(toId);
    if (toTask == null) {
      return Failure(TaskLinkAddToNotFound(command.toTaskId));
    }

    // Check for duplicate
    final existing = await _linkRepository.get(fromId, toId, linkType);
    if (existing != null) {
      return Failure(
        TaskLinkAddAlreadyExists(
          fromTaskId: command.fromTaskId,
          toTaskId: command.toTaskId,
          linkType: command.linkType,
        ),
      );
    }

    // Cycle detection for strong links
    if (linkType.isStrong) {
      // Load all strong links for the project by fetching links of both tasks
      // and then building adjacency from the relevant task set.
      final projectTasks = await _taskRepository.getByProjectId(
        fromTask.projectId,
      );
      final projectTaskIds = projectTasks.map((t) => TaskId(t.id.raw)).toList();
      final allLinks = await _linkRepository.getAllByProjectLinks(
        projectTaskIds,
      );

      final adj = buildStrongAdjacency(allLinks);
      try {
        detectCycle(adj, extraFrom: fromId.raw, extraTo: toId.raw);
      } on CycleException catch (e) {
        return Failure(TaskLinkAddCycleDetected(e.path));
      }
    }

    // Save the new link
    final link = TaskLink(
      id: const Uuid().v7(),
      fromTaskId: fromId,
      toTaskId: toId,
      linkType: linkType,
      createdAt: DateTime.now(),
      label: command.label,
    );
    final saved = await _linkRepository.save(link);

    await _bus.publish(
      DomainEvent.taskLinkAdded(
        fromTaskId: fromId,
        toTaskId: toId,
        linkType: command.linkType,
      ),
    );

    return Success(saved);
  }
}
