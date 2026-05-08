import 'package:uuid/uuid.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/enums/task_completion_policy.dart';
import '../../../domain/enums/task_context_state.dart';
import '../../../domain/enums/task_last_action_type.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/cycle_exception.dart';
import '../../../domain/exceptions/reflection_exceptions.dart';
import '../../../domain/result.dart';
import '../../../domain/services/reflection_domain_services.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/services/task_graph.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../../events/event_bus.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_replan_command.dart';
import 'failures/task_replan_failure.dart';
import 'policy/task_exists_policy.dart';

class TaskReplanAppliedChange {
  const TaskReplanAppliedChange({required this.action, required this.result});

  final String action;
  final Object? result;
}

class TaskReplanResult {
  const TaskReplanResult({
    required this.applied,
    required this.planVersion,
    required this.summary,
  });

  final List<TaskReplanAppliedChange> applied;
  final int planVersion;
  final String summary;
}

typedef _Operation =
    Operation<TaskReplanCommand, TaskReplanResult, TaskReplanFailure>;

class TaskReplanOperation extends _Operation {
  TaskReplanOperation(
    super.pipeline,
    this._taskRepository,
    this._taskLinkRepository,
    this._bus,
  );

  final TaskRepository _taskRepository;
  final TaskLinkRepository _taskLinkRepository;
  final EventBus _bus;

  @override
  String get operationName => 'TaskReplanOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskReplanCommand command) => {
    'taskId': command.taskId,
    'changesCount': command.changes.length,
  };

  @override
  PolicySet<TaskReplanCommand, TaskReplanFailure> preconditionPolicies(
    TaskReplanCommand command,
    OperationContext context,
  ) => PolicySet([
    TaskExistsPolicy(
      _taskRepository,
      (cmd) => cmd.taskId,
      TaskReplanNotFound.new,
    ),
  ]);

  @override
  Future<Result<TaskReplanResult, TaskReplanFailure>> run(
    TaskReplanCommand command,
  ) async {
    final task = await _taskRepository.getById(command.taskId);
    if (task == null) {
      return Failure(TaskReplanNotFound(command.taskId));
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
      return Failure(TaskReplanStallDetected(error.message));
    }

    final applied = <TaskReplanAppliedChange>[];

    for (final change in command.changes) {
      final result = await _applyChange(task, change);
      if (result case Failure<TaskReplanAppliedChange, TaskReplanFailure>()) {
        return Failure(result.error);
      }
      applied.add(
        (result as Success<TaskReplanAppliedChange, TaskReplanFailure>).value,
      );
    }

    final now = DateTime.now().toUtc();
    final createdCount = applied
        .where((change) => change.action == 'add_task')
        .length;
    final updatedTask = task.copyWith(
      planVersion: task.planVersion + 1,
      lastActionType: TaskLastActionType.planning,
      metadata: appendTaskPnrWindow(
        task.copyWith(
          metadata: appendTaskActionHistory(task, TaskLastActionType.planning),
        ),
        created: createdCount,
      ),
      updatedAt: now,
    );
    final savedTask = await _taskRepository.save(updatedTask);
    await _bus.publish(DomainEvent.taskReplanned(taskId: savedTask.id));

    return Success(
      TaskReplanResult(
        applied: applied,
        planVersion: savedTask.planVersion,
        summary: 'Applied ${applied.length} replan changes',
      ),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _applyChange(
    Task task,
    ReplanChange change,
  ) => switch (change.action) {
    .addTask => _addTask(task, change.params),
    .removeTask => _removeTask(change.params),
    .addLink => _addLink(task, change.params),
    .removeLink => _removeLink(change.params),
    .updateTask => _updateTask(change.params),
    .setContext => _setContext(change.params),
    .setPriority => _setPriority(change.params),
    .setPolicy => _setPolicy(change.params),
  };

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _addTask(
    Task rootTask,
    Map<String, dynamic> params,
  ) async {
    final titleRaw = params['title'];
    if (titleRaw is! String || titleRaw.trim().isEmpty) {
      return const Failure(
        TaskReplanValidationError('add_task requires title'),
      );
    }

    TaskId? parentId;
    final parentIdRaw = params['parentId'];
    if (parentIdRaw is String) {
      try {
        parentId = TaskId(parentIdRaw);
      } on FormatException {
        return Failure(
          TaskReplanValidationError('Invalid add_task parentId: $parentIdRaw'),
        );
      }
    }

    TaskDescription? description;
    final descriptionRaw = params['description'];
    if (descriptionRaw is String && descriptionRaw.trim().isNotEmpty) {
      if (descriptionRaw.trim().length > 500) {
        return const Failure(
          TaskReplanValidationError(
            'description cannot exceed 500 characters',
          ),
        );
      }
      description = TaskDescription(descriptionRaw.trim());
    }

    final now = DateTime.now().toUtc();
    final newTask = Task(
      id: TaskId.generate(),
      projectId: rootTask.projectId,
      title: TaskTitle(titleRaw.trim()),
      status: TaskStatus.pending,
      contextState: TaskContextState.active,
      completionPolicy: TaskCompletionPolicy.allChildren,
      businessValue: 50,
      urgencyScore: 50,
      lastActionType: TaskLastActionType.execution,
      lastProgressAt: now,
      createdAt: now,
      updatedAt: now,
      tags: const [],
      metadata: const {},
      planVersion: 0,
      parentId: parentId ?? rootTask.id,
      description: description,
    );
    final saved = await _taskRepository.save(newTask);
    await _bus.publish(DomainEvent.taskCreated(taskId: saved.id));
    return Success(TaskReplanAppliedChange(action: 'add_task', result: saved));
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _removeTask(
    Map<String, dynamic> params,
  ) async {
    final taskIdRaw = params['taskId'];
    if (taskIdRaw is! TaskId) {
      return const Failure(
        TaskReplanValidationError('remove_task requires taskId'),
      );
    }

    late final TaskId taskId;
    try {
      taskId = taskIdRaw;
    } on FormatException {
      return Failure(TaskReplanValidationError('Invalid taskId: $taskIdRaw'));
    }

    final existing = await _taskRepository.getById(taskId);
    if (existing == null) {
      return Failure(TaskReplanNotFound(taskId));
    }

    await _taskRepository.delete(taskId);
    await _bus.publish(DomainEvent.taskDeleted(taskId: taskId));
    return Success(
      TaskReplanAppliedChange(action: 'remove_task', result: taskId),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _addLink(
    Task rootTask,
    Map<String, dynamic> params,
  ) async {
    final fromRaw = params['fromTaskId'];
    final toRaw = params['toTaskId'];
    final typeRaw = params['linkType'];
    if (fromRaw is! String || toRaw is! String || typeRaw is! String) {
      return const Failure(
        TaskReplanValidationError(
          'add_link requires fromTaskId, toTaskId and linkType',
        ),
      );
    }

    late final TaskId fromId;
    late final TaskId toId;
    try {
      fromId = TaskId(fromRaw);
      toId = TaskId(toRaw);
    } on FormatException {
      return const Failure(
        TaskReplanValidationError('add_link requires valid task ids'),
      );
    }

    final linkType = LinkType.values
        .where((value) => value.value == typeRaw)
        .firstOrNull;
    if (linkType == null) {
      return Failure(TaskReplanValidationError('Invalid link type: $typeRaw'));
    }

    final fromTask = await _taskRepository.getById(fromId);
    final toTask = await _taskRepository.getById(toId);
    if (fromTask == null || toTask == null) {
      return const Failure(
        TaskReplanValidationError('add_link requires existing tasks'),
      );
    }

    if (linkType == .strong) {
      final projectTasks = await _taskRepository.getByProjectId(
        rootTask.projectId,
      );
      final allLinks = await _taskLinkRepository.getAllByProjectLinks(
        projectTasks.map((task) => task.id).toList(),
      );
      try {
        detectCycle(
          buildStrongAdjacency(allLinks),
          extraFrom: fromId,
          extraTo: toId,
        );
      } on CycleException catch (error) {
        return Failure(TaskReplanCycleDetected(error.path));
      }
    }

    final link = TaskLink(
      id: const Uuid().v7(),
      fromTaskId: fromId,
      toTaskId: toId,
      linkType: linkType,
      createdAt: DateTime.now().toUtc(),
      label: params['label'] as String?,
    );
    final saved = await _taskLinkRepository.save(link);
    await _bus.publish(
      DomainEvent.taskLinkAdded(
        fromTaskId: fromId,
        toTaskId: toId,
        linkType: linkType,
      ),
    );
    return Success(TaskReplanAppliedChange(action: 'add_link', result: saved));
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _removeLink(
    Map<String, dynamic> params,
  ) async {
    final fromRaw = params['fromTaskId'];
    final toRaw = params['toTaskId'];
    if (fromRaw is! String || toRaw is! String) {
      return const Failure(
        TaskReplanValidationError(
          'remove_link requires fromTaskId and toTaskId',
        ),
      );
    }

    late final TaskId fromId;
    late final TaskId toId;
    try {
      fromId = TaskId(fromRaw);
      toId = TaskId(toRaw);
    } on FormatException {
      return const Failure(
        TaskReplanValidationError('remove_link requires valid task ids'),
      );
    }

    LinkType? linkType;
    final typeRaw = params['linkType'];
    if (typeRaw != null) {
      if (typeRaw is! String) {
        return const Failure(
          TaskReplanValidationError('remove_link linkType must be string'),
        );
      }
      linkType = LinkType.values
          .where((value) => value.value == typeRaw)
          .firstOrNull;
      if (linkType == null) {
        return Failure(
          TaskReplanValidationError('Invalid link type: $typeRaw'),
        );
      }
    }

    await _taskLinkRepository.delete(fromId, toId, linkType);
    await _bus.publish(
      DomainEvent.taskLinkRemoved(
        fromTaskId: fromId,
        toTaskId: toId,
        linkType: linkType!,
      ),
    );
    return Success(
      TaskReplanAppliedChange(
        action: 'remove_link',
        result: '$fromRaw->$toRaw',
      ),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _updateTask(
    Map<String, dynamic> params,
  ) async {
    final taskResult = await _loadTargetTask(params, actionName: 'update_task');
    if (taskResult case Failure<Task, TaskReplanFailure>()) {
      return Failure(taskResult.error);
    }
    final task = (taskResult as Success<Task, TaskReplanFailure>).value;

    TaskTitle? title;
    final titleRaw = params['title'];
    if (titleRaw is String) {
      if (titleRaw.trim().isEmpty) {
        return const Failure(
          TaskReplanValidationError('title cannot be empty'),
        );
      }
      title = TaskTitle(titleRaw.trim());
    }

    TaskDescription? description;
    final descriptionRaw = params['description'];
    if (descriptionRaw is String) {
      if (descriptionRaw.trim().isEmpty) {
        return const Failure(
          TaskReplanValidationError('description cannot be empty'),
        );
      }
      if (descriptionRaw.trim().length > 500) {
        return const Failure(
          TaskReplanValidationError(
            'description cannot exceed 500 characters',
          ),
        );
      }
      description = TaskDescription(descriptionRaw.trim());
    }

    final updated = task.copyWith(
      title: title ?? task.title,
      description: description ?? task.description,
      updatedAt: DateTime.now().toUtc(),
    );
    final saved = await _taskRepository.save(updated);
    await _bus.publish(DomainEvent.taskUpdated(taskId: saved.id));
    return Success(
      TaskReplanAppliedChange(action: 'update_task', result: saved),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _setContext(
    Map<String, dynamic> params,
  ) async {
    final taskResult = await _loadTargetTask(params, actionName: 'set_context');
    if (taskResult case Failure<Task, TaskReplanFailure>()) {
      return Failure(taskResult.error);
    }
    final task = (taskResult as Success<Task, TaskReplanFailure>).value;

    final stateRaw = params['contextState'];
    if (stateRaw is! String) {
      return const Failure(
        TaskReplanValidationError('set_context requires contextState'),
      );
    }
    final context = TaskContextState.values
        .where((value) => value.value == stateRaw)
        .firstOrNull;
    if (context == null) {
      return Failure(
        TaskReplanValidationError('Invalid contextState: $stateRaw'),
      );
    }

    final saved = await _taskRepository.save(
      task.copyWith(contextState: context, updatedAt: DateTime.now().toUtc()),
    );
    await _bus.publish(
      DomainEvent.taskContextChanged(
        taskId: saved.id,
        contextState: context.value,
      ),
    );
    return Success(
      TaskReplanAppliedChange(action: 'set_context', result: saved),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _setPriority(
    Map<String, dynamic> params,
  ) async {
    final taskResult = await _loadTargetTask(
      params,
      actionName: 'set_priority',
    );
    if (taskResult case Failure<Task, TaskReplanFailure>()) {
      return Failure(taskResult.error);
    }
    final task = (taskResult as Success<Task, TaskReplanFailure>).value;

    final businessValue = params['businessValue'];
    final urgencyScore = params['urgencyScore'];
    if (businessValue is! int || urgencyScore is! int) {
      return const Failure(
        TaskReplanValidationError(
          'set_priority requires businessValue and urgencyScore',
        ),
      );
    }
    if (businessValue < 0 || businessValue > 100) {
      return const Failure(
        TaskReplanValidationError('businessValue must be between 0 and 100'),
      );
    }
    if (urgencyScore < 0 || urgencyScore > 100) {
      return const Failure(
        TaskReplanValidationError('urgencyScore must be between 0 and 100'),
      );
    }

    final saved = await _taskRepository.save(
      task.copyWith(
        businessValue: businessValue,
        urgencyScore: urgencyScore,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await _bus.publish(DomainEvent.taskUpdated(taskId: saved.id));
    return Success(
      TaskReplanAppliedChange(action: 'set_priority', result: saved),
    );
  }

  Future<Result<TaskReplanAppliedChange, TaskReplanFailure>> _setPolicy(
    Map<String, dynamic> params,
  ) async {
    final taskResult = await _loadTargetTask(params, actionName: 'set_policy');
    if (taskResult case Failure<Task, TaskReplanFailure>()) {
      return Failure(taskResult.error);
    }
    final task = (taskResult as Success<Task, TaskReplanFailure>).value;

    final policyRaw = params['completionPolicy'];
    if (policyRaw is! String) {
      return const Failure(
        TaskReplanValidationError('set_policy requires completionPolicy'),
      );
    }
    final policy = TaskCompletionPolicy.values
        .where((value) => value.value == policyRaw)
        .firstOrNull;
    if (policy == null) {
      return Failure(
        TaskReplanValidationError('Invalid completionPolicy: $policyRaw'),
      );
    }

    final saved = await _taskRepository.save(
      task.copyWith(
        completionPolicy: policy,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await _bus.publish(DomainEvent.taskUpdated(taskId: saved.id));
    return Success(
      TaskReplanAppliedChange(action: 'set_policy', result: saved),
    );
  }

  Future<Result<Task, TaskReplanFailure>> _loadTargetTask(
    Map<String, dynamic> params, {
    required String actionName,
  }) async {
    final taskIdRaw = params['taskId'];
    if (taskIdRaw is! TaskId) {
      return Failure(TaskReplanValidationError('$actionName requires taskId'));
    }

    final taskId = taskIdRaw;

    final task = await _taskRepository.getById(taskId);
    if (task == null) {
      return Failure(TaskReplanNotFound(taskIdRaw));
    }

    return Success(task);
  }
}
