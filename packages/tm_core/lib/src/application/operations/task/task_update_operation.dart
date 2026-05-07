import '../../../domain/entities/task.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_update_command.dart';
import 'failures/task_update_failure.dart';
import 'policy/task_exists_policy.dart';

typedef _Operation = Operation<TaskUpdateCommand, Task, TaskUpdateFailure>;

class TaskUpdateOperation extends _Operation {
  TaskUpdateOperation(super.pipeline, this._repository, this._bus);

  final TaskRepository _repository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskUpdateOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskUpdateCommand command) => {
    'taskId': command.taskId,
  };

  @override
  OperationPolicySet<TaskUpdateCommand, TaskUpdateFailure> preconditionPolicies(
    TaskUpdateCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy(_repository, (cmd) => cmd.taskId, TaskUpdateNotFound.new),
  ]);

  @override
  Future<Result<Task, TaskUpdateFailure>> run(TaskUpdateCommand command) async {
    final task = await _repository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskUpdateNotFound(command.taskId));
    }

    // Validate title if provided
    TaskTitle? newTitle;
    if (command.title != null) {
      if (command.title!.isEmpty) {
        return const Failure(TaskUpdateInvalidTitle('title cannot be empty'));
      }
      newTitle = TaskTitle(command.title!);
    }

    // Validate description if provided (and not clearing)
    TaskDescription? newDescription;
    if (command.description != null && !command.clearDescription) {
      if (command.description!.isEmpty) {
        return const Failure(
          TaskUpdateInvalidDescription('description cannot be empty'),
        );
      }
      if (command.description!.length > 500) {
        return const Failure(
          TaskUpdateInvalidDescription(
            'description cannot exceed 500 characters',
          ),
        );
      }
      newDescription = TaskDescription(command.description!);
    }

    // Validate score ranges
    if (command.businessValue != null &&
        (command.businessValue! < 0 || command.businessValue! > 100)) {
      return Failure(TaskUpdateInvalidBusinessValue(command.businessValue!));
    }
    if (command.urgencyScore != null &&
        (command.urgencyScore! < 0 || command.urgencyScore! > 100)) {
      return Failure(TaskUpdateInvalidUrgencyScore(command.urgencyScore!));
    }

    final now = DateTime.now().toUtc();

    final updated = task.copyWith(
      title: newTitle ?? task.title,
      description: command.clearDescription
          ? null
          : (newDescription ?? task.description),
      businessValue: command.businessValue ?? task.businessValue,
      urgencyScore: command.urgencyScore ?? task.urgencyScore,
      estimatedEffort: command.estimatedEffort ?? task.estimatedEffort,
      dueDate: command.clearDueDate ? null : (command.dueDate ?? task.dueDate),
      assignedTo: command.clearAssignedTo
          ? null
          : (command.assignedTo ?? task.assignedTo),
      tags: command.tags ?? task.tags,
      updatedAt: now,
    );

    final saved = await _repository.save(updated);
    await _bus.publish(DomainEvent.taskUpdated(taskId: saved.id));

    return Success(saved);
  }
}
