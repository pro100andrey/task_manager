import '../../../domain/enums/link_type.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_link_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_link_remove_command.dart';
import 'failures/task_link_remove_failure.dart';

typedef _Operation =
    Operation<TaskLinkRemoveCommand, void, TaskLinkRemoveFailure>;

class TaskLinkRemoveOperation extends _Operation {
  TaskLinkRemoveOperation(super.pipeline, this._linkRepository, this._bus);

  final TaskLinkRepository _linkRepository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskLinkRemoveOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskLinkRemoveCommand command) => {
    'fromTaskId': command.fromTaskId,
    'toTaskId': command.toTaskId,
    'linkType': command.linkType,
  };

  @override
  OperationPolicySet<TaskLinkRemoveCommand, TaskLinkRemoveFailure>
  preconditionPolicies(
    TaskLinkRemoveCommand command,
    OperationContext context,
  ) => const OperationPolicySet([]);

  @override
  Future<Result<void, TaskLinkRemoveFailure>> run(
    TaskLinkRemoveCommand command,
  ) async {
    // Validate IDs
    late final TaskId fromId;
    late final TaskId toId;
    try {
      fromId = command.fromTaskId;
      toId = command.toTaskId;
    } on FormatException {
      return Failure(
        TaskLinkRemoveNotFound(
          fromTaskId: command.fromTaskId,
          toTaskId: command.toTaskId,
          linkType: command.linkType,
        ),
      );
    }

    // Parse optional link type
    LinkType? linkType;
    if (command.linkType != null) {
      linkType = LinkType.values
          .where((lt) => lt == command.linkType)
          .firstOrNull;
      if (linkType == null) {
        return Failure(TaskLinkRemoveInvalidLinkType(command.linkType!));
      }
    }

    // Verify at least one link exists
    if (linkType != null) {
      final existing = await _linkRepository.get(fromId, toId, linkType);
      if (existing == null) {
        return Failure(
          TaskLinkRemoveNotFound(
            fromTaskId: command.fromTaskId,
            toTaskId: command.toTaskId,
            linkType: command.linkType,
          ),
        );
      }
    } else {
      // Check any link exists between the two tasks
      final links = await _linkRepository.getByTaskId(fromId);
      final hasPair = links.any(
        (l) => l.fromTaskId == fromId && l.toTaskId == toId,
      );
      if (!hasPair) {
        return Failure(
          TaskLinkRemoveNotFound(
            fromTaskId: command.fromTaskId,
            toTaskId: command.toTaskId,
          ),
        );
      }
    }

    await _linkRepository.delete(fromId, toId, linkType);

    // Publish one event per removed link type
    final removedTypes = linkType != null
        ? [linkType]
        : LinkType.values.toList();
    for (final lt in removedTypes) {
      await _bus.publish(
        DomainEvent.taskLinkRemoved(
          fromTaskId: fromId,
          toTaskId: toId,
          linkType: lt.value,
        ),
      );
    }

    return const Success(null);
  }
}
