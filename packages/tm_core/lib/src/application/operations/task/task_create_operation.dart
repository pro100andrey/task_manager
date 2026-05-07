import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_last_action_type.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/task_exceptions.dart';
import '../../../domain/result.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/task/task_alias.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/project_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_create_command.dart';
import 'failures/task_create_failure.dart';
import 'policy/task_create_input_valid_policy.dart';

typedef _Operation = Operation<TaskCreateCommand, Task, TaskCreateFailure>;

class TaskCreateOperation extends _Operation {
  TaskCreateOperation(
    super.pipeline,
    this._taskRepository,
    this._projectRepository,
    this._bus,
  );

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskCreateOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskCreateCommand command) => {
    'projectId': command.projectId,
    'title': command.title,
  };

  @override
  OperationPolicySet<TaskCreateCommand, TaskCreateFailure> preconditionPolicies(
    TaskCreateCommand command,
    OperationContext context,
  ) => OperationPolicySet([TaskCreateInputValidPolicy()]);

  @override
  Future<Result<Task, TaskCreateFailure>> run(
    TaskCreateCommand command,
  ) async {
    // Validate projectId and ensure project exists

    if (command.projectId.formatError case final _?) {
      return Failure(TaskCreateProjectNotFound(command.projectId));
    }

    final project = await _projectRepository.getById(command.projectId);
    if (project == null) {
      return Failure(TaskCreateProjectNotFound(command.projectId));
    }

    // Validate parentId if provided
    TaskId? parentId;
    if (command.parentId != null) {
      try {
        final parent = await _taskRepository.getById(command.parentId!);
        if (parent == null) {
          return Failure(TaskCreateParentNotFound(command.parentId!));
        }
        parentId = command.parentId;
      } on FormatException {
        return Failure(TaskCreateParentNotFound(command.parentId!));
      }
    }

    // Validate and normalize alias if provided
    TaskAlias? alias;
    String? normalizedAlias;
    if (command.alias != null) {
      try {
        normalizedAlias = normalizeAlias(command.alias!);
        alias = TaskAlias(normalizedAlias);
      } on InvalidAliasException catch (e) {
        return Failure(TaskCreateInvalidAlias(e.reason));
      }

      // Check alias uniqueness
      final existing = await _taskRepository.getByAlias(
        command.projectId,
        alias,
      );
      if (existing != null) {
        return Failure(TaskCreateAliasAlreadyExists(normalizedAlias));
      }
    }

    final title = TaskTitle(command.title.trim());
    final description = command.description != null
        ? TaskDescription(command.description!.trim())
        : null;

    final now = DateTime.now().toUtc();
    final task = Task(
      id: TaskId.generate(),
      projectId: command.projectId,
      title: title,
      status: TaskStatus.pending,
      contextState: command.contextState,
      completionPolicy: command.completionPolicy,
      businessValue: command.businessValue,
      urgencyScore: command.urgencyScore,
      lastActionType: TaskLastActionType.execution,
      lastProgressAt: now,
      createdAt: now,
      updatedAt: now,
      tags: command.tags,
      metadata: command.metadata,
      planVersion: 0,
      parentId: parentId,
      alias: alias,
      normalizedAlias: normalizedAlias,
      description: description,
      estimatedEffort: command.estimatedEffort,
      dueDate: command.dueDate,
      assignedTo: command.assignedTo,
    );

    final saved = await _taskRepository.save(task);
    await _bus.publish(TaskCreatedEvent(taskId: saved.id));

    return Success(saved);
  }
}
