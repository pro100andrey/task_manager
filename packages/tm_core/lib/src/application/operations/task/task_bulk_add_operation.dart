import '../../../domain/entities/task.dart';
import '../../../domain/enums/task_completion_policy.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/enums/task_last_action_type.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/result.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../../events/event_bus.dart';
import '../../ports/project_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_bulk_add_command.dart';
import 'failures/task_bulk_add_failure.dart';

class TaskBulkAddResult {
  const TaskBulkAddResult({
    required this.tasks,
    required this.count,
  });

  final List<Task> tasks;
  final int count;
}

typedef _Operation =
    Operation<TaskBulkAddCommand, TaskBulkAddResult, TaskBulkAddFailure>;

class TaskBulkAddOperation extends _Operation {
  TaskBulkAddOperation(
    super.pipeline,
    this._taskRepository,
    this._projectRepository,
    this._bus,
  );

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final EventBus _bus;

  static const maxBulkSize = 100;

  @override
  String get operationName => 'TaskBulkAddOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskBulkAddCommand command) => {
    'projectId': command.projectId,
    'tasksCount': command.tasks.length,
  };

  @override
  OperationPolicySet<TaskBulkAddCommand, TaskBulkAddFailure>
  preconditionPolicies(
    TaskBulkAddCommand command,
    OperationContext context,
  ) => const OperationPolicySet([]);

  @override
  Future<Result<TaskBulkAddResult, TaskBulkAddFailure>> run(
    TaskBulkAddCommand command,
  ) async {
    // Validate bulk size
    if (command.tasks.isEmpty) {
      return const Failure(
        TaskBulkAddValidationError('bulk_add requires at least one task'),
      );
    }

    if (command.tasks.length > maxBulkSize) {
      return Failure(
        TaskBulkAddTooManyTasks(command.tasks.length, maxBulkSize),
      );
    }

    // Validate project exists

    if (command.projectId.formatError case final _?) {
      return Failure(TaskBulkAddProjectNotFound(command.projectId));
    }

    final project = await _projectRepository.getById(command.projectId);
    if (project == null) {
      return Failure(TaskBulkAddProjectNotFound(command.projectId));
    }

    // Validate all parent references
    for (final spec in command.tasks) {
      if (spec.parentId != null) {
        try {
          final pid = spec.parentId!;
          final parent = await _taskRepository.getById(pid);
          if (parent == null) {
            return Failure(TaskBulkAddParentNotFound(spec.parentId!));
          }
          // Ensure parent is in same project
          if (parent.projectId != command.projectId) {
            return Failure(TaskBulkAddParentNotFound(spec.parentId!));
          }
        } on FormatException {
          return Failure(TaskBulkAddParentNotFound(spec.parentId!));
        }
      }
    }

    // Create tasks
    final createdTasks = <Task>[];
    final now = DateTime.now().toUtc();

    for (var i = 0; i < command.tasks.length; i++) {
      final spec = command.tasks[i];
      TaskId? parentId;
      if (spec.parentId != null) {
        try {
          parentId = spec.parentId;
        } on FormatException {
          return Failure(TaskBulkAddParentNotFound(spec.parentId!));
        }
      }

      final trimmedTitle = spec.title.trim();
      if (trimmedTitle.isEmpty) {
        return Failure(
          TaskBulkAddTaskCreationFailed(i, 'title cannot be empty'),
        );
      }
      final title = TaskTitle(trimmedTitle);

      final description = spec.description != null
          ? TaskDescription(spec.description!.trim())
          : null;

      final contextState = spec.contextState ?? TaskContextState.active;

      final completionPolicy =
          spec.completionPolicy ?? TaskCompletionPolicy.allChildren;

      final task = Task(
        id: TaskId.generate(),
        projectId: command.projectId,
        title: title,
        status: TaskStatus.pending,
        contextState: contextState,
        completionPolicy: completionPolicy,
        businessValue: spec.businessValue,
        urgencyScore: spec.urgencyScore,
        lastActionType: TaskLastActionType.execution,
        lastProgressAt: now,
        createdAt: now,
        updatedAt: now,
        tags: const [],
        metadata: const {},
        planVersion: 0,
        parentId: parentId,
        description: description,
      );

      final saved = await _taskRepository.save(task);
      createdTasks.add(saved);
      await _bus.publish(TaskCreatedEvent(taskId: saved.id));
    }

    return Success(
      TaskBulkAddResult(
        tasks: createdTasks,
        count: createdTasks.length,
      ),
    );
  }
}
