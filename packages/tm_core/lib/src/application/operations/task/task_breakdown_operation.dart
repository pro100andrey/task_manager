import 'package:uuid/uuid.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/enums/task_completion_policy.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/enums/task_last_action_type.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/reflection_exceptions.dart';
import '../../../domain/result.dart';
import '../../../domain/services/reflection_domain_services.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../ports/domain_event_bus.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_breakdown_command.dart';
import 'failures/task_breakdown_failure.dart';
import 'policy/task_exists_policy.dart';

class TaskBreakdownResult {
  const TaskBreakdownResult({
    required this.task,
    required this.subtasks,
    required this.links,
    required this.planVersion,
  });

  final Task task;
  final List<Task> subtasks;
  final List<TaskLink> links;
  final int planVersion;
}

typedef _Operation =
    Operation<TaskBreakdownCommand, TaskBreakdownResult, TaskBreakdownFailure>;

class TaskBreakdownOperation extends _Operation {
  TaskBreakdownOperation(
    super.pipeline,
    this._taskRepository,
    this._taskLinkRepository,
    this._bus,
  );

  final TaskRepository _taskRepository;
  final TaskLinkRepository _taskLinkRepository;
  final DomainEventBus _bus;

  @override
  String get operationName => 'TaskBreakdownOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskBreakdownCommand command) => {
    'taskId': command.taskId,
    'mode': command.mode,
    'subtasksCount': command.subtasks.length,
  };

  @override
  OperationPolicySet<TaskBreakdownCommand, TaskBreakdownFailure>
  preconditionPolicies(
    TaskBreakdownCommand command,
    OperationContext context,
  ) => OperationPolicySet([
    TaskExistsPolicy<TaskBreakdownCommand, TaskBreakdownFailure>(
      _taskRepository,
      (cmd) => cmd.taskId,
      TaskBreakdownNotFound.new,
    ),
  ]);

  @override
  Future<Result<TaskBreakdownResult, TaskBreakdownFailure>> run(
    TaskBreakdownCommand command,
  ) async {
    final task = await _taskRepository.getById(TaskId(command.taskId));
    if (task == null) {
      return Failure(TaskBreakdownNotFound(command.taskId));
    }

    if (command.subtasks.isEmpty) {
      return const Failure(
        TaskBreakdownValidationError('task_breakdown requires subtasks'),
      );
    }

    final mode = switch (command.mode) {
      'parallel' => 'parallel',
      'sequence' => 'sequence',
      _ => null,
    };
    if (mode == null) {
      return Failure(
        TaskBreakdownValidationError(
          'Invalid task_breakdown mode: ${command.mode}',
        ),
      );
    }

    try {
      final windows = taskPnrWindows(task);
      final deltaCreated = windows.fold<int>(
        0,
        (sum, window) => sum + window.created,
      );
      final deltaCompleted = windows.fold<int>(
        0,
        (sum, window) => sum + window.completed,
      );
      checkPNR(
        PnrHistorySnapshot(
          deltaCompleted: deltaCompleted,
          deltaCreated: deltaCreated,
          recentActions: taskActionHistory(task).reversed.toList(),
        ),
      );
    } on StallDetectedException catch (error) {
      return Failure(TaskBreakdownStallDetected(error.message));
    }

    final now = DateTime.now().toUtc();
    final createdTasks = <Task>[];

    for (final subtask in command.subtasks) {
      final titleRaw = subtask.title.trim();
      if (titleRaw.isEmpty) {
        return const Failure(
          TaskBreakdownValidationError('subtask title cannot be empty'),
        );
      }
      if (subtask.businessValue < 0 || subtask.businessValue > 100) {
        return const Failure(
          TaskBreakdownValidationError(
            'subtask businessValue must be between 0 and 100',
          ),
        );
      }
      if (subtask.urgencyScore < 0 || subtask.urgencyScore > 100) {
        return const Failure(
          TaskBreakdownValidationError(
            'subtask urgencyScore must be between 0 and 100',
          ),
        );
      }

      TaskDescription? description;
      final descriptionRaw = subtask.description?.trim();
      if (descriptionRaw != null && descriptionRaw.isNotEmpty) {
        if (descriptionRaw.length > 500) {
          return const Failure(
            TaskBreakdownValidationError(
              'subtask description cannot exceed 500 characters',
            ),
          );
        }
        description = TaskDescription(descriptionRaw);
      }

      final created = Task(
        id: TaskId.generate(),
        projectId: task.projectId,
        title: TaskTitle(titleRaw),
        status: TaskStatus.pending,
        contextState: TaskContextState.active,
        completionPolicy: TaskCompletionPolicy.allChildren,
        businessValue: subtask.businessValue,
        urgencyScore: subtask.urgencyScore,
        lastActionType: TaskLastActionType.execution,
        lastProgressAt: now,
        createdAt: now,
        updatedAt: now,
        tags: const [],
        metadata: const {},
        planVersion: 0,
        parentId: task.id,
        description: description,
      );
      final saved = await _taskRepository.save(created);
      createdTasks.add(saved);
      await _bus.publish(DomainEvent.taskCreated(taskId: saved.id));
    }

    final links = <TaskLink>[];
    if (mode == 'sequence') {
      for (var index = 0; index < createdTasks.length - 1; index++) {
        final link = TaskLink(
          id: const Uuid().v7(),
          fromTaskId: createdTasks[index].id,
          toTaskId: createdTasks[index + 1].id,
          linkType: LinkType.strong,
          createdAt: now,
          label: 'task_breakdown:sequence',
        );
        final savedLink = await _taskLinkRepository.save(link);
        links.add(savedLink);
        await _bus.publish(
          DomainEvent.taskLinkAdded(
            fromTaskId: savedLink.fromTaskId,
            toTaskId: savedLink.toTaskId,
            linkType: savedLink.linkType.value,
          ),
        );
      }
    }

    final updatedTask = task.copyWith(
      planVersion: task.planVersion + 1,
      lastActionType: TaskLastActionType.planning,
      metadata: appendTaskPnrWindow(
        task.copyWith(
          metadata: appendTaskActionHistory(task, TaskLastActionType.planning),
        ),
        created: createdTasks.length,
      ),
      updatedAt: now,
    );
    final savedTask = await _taskRepository.save(updatedTask);
    await _bus.publish(DomainEvent.taskReplanned(taskId: savedTask.id));

    return Success(
      TaskBreakdownResult(
        task: savedTask,
        subtasks: createdTasks,
        links: links,
        planVersion: savedTask.planVersion,
      ),
    );
  }
}
