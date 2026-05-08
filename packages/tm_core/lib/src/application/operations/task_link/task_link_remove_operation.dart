import '../../../domain/enums/link_type.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../ports/event_bus.dart';
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
  final EventBus _bus;

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
    if (command.fromTaskId.formatError case _?) {
      return Failure(
        TaskLinkRemoveNotFound(
          fromTaskId: command.fromTaskId,
          toTaskId: command.toTaskId,
          linkType: command.linkType,
        ),
      );
    }

    var linkType = command.linkType;

    if (linkType == LinkType.unknown) {
      return Failure(TaskLinkRemoveInvalidLinkType(linkType!));
    }

    if (linkType == null) {
      // Remove all link types between the two tasks
      final links = await _linkRepository.getByTaskId(command.fromTaskId);
      final pairLinks = links
          .where(
            (l) =>
                l.fromTaskId == command.fromTaskId &&
                l.toTaskId == command.toTaskId,
          )
          .toList();

      if (pairLinks.isEmpty) {
        return Failure(
          TaskLinkRemoveNotFound(
            fromTaskId: command.fromTaskId,
            toTaskId: command.toTaskId,
            linkType: command.linkType,
          ),
        );
      }

      await _linkRepository.delete(command.fromTaskId, command.toTaskId, null);

      for (final link in pairLinks) {
        await _bus.publish(
          DomainEvent.taskLinkRemoved(
            fromTaskId: command.fromTaskId,
            toTaskId: command.toTaskId,
            linkType: link.linkType,
          ),
        );
      }
    } else {
      final existing = await _linkRepository.get(
        command.fromTaskId,
        command.toTaskId,
        linkType,
      );

      if (existing == null) {
        return Failure(
          TaskLinkRemoveNotFound(
            fromTaskId: command.fromTaskId,
            toTaskId: command.toTaskId,
            linkType: command.linkType,
          ),
        );
      }

      linkType = existing.linkType;

      await _linkRepository.delete(
        command.fromTaskId,
        command.toTaskId,
        linkType,
      );

      await _bus.publish(
        DomainEvent.taskLinkRemoved(
          fromTaskId: command.fromTaskId,
          toTaskId: command.toTaskId,
          linkType: linkType,
        ),
      );
    }

    return const Success(null);
  }
}
