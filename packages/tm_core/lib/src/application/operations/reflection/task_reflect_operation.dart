import 'package:uuid/uuid.dart';

import '../../../domain/entities/reflection.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_link.dart';
import '../../../domain/enums/link_type.dart';
import '../../../domain/events/domain_event.dart';
import '../../../domain/exceptions/reflection_exceptions.dart';
import '../../../domain/result.dart';
import '../../../domain/services/reflection_domain_services.dart';
import '../../../domain/services/task_domain_services.dart';
import '../../../domain/value_objects/task/task_id.dart';
import '../../../events/event_bus.dart';
import '../../ports/project_repository.dart';
import '../../ports/reflection_repository.dart';
import '../../ports/task_link_repository.dart';
import '../../ports/task_repository.dart';
import '../operation.dart';
import '../operation_context.dart';
import '../operation_policy.dart';
import 'commands/task_reflect_command.dart';
import 'failures/task_reflect_failure.dart';

class TaskReflectResult {
  const TaskReflectResult({required this.reflection, this.replanTask});

  final Reflection reflection;
  final Task? replanTask;
}

typedef _Operation =
    Operation<TaskReflectCommand, TaskReflectResult, TaskReflectFailure>;

class TaskReflectOperation extends _Operation {
  TaskReflectOperation(
    super.pipeline,
    this._projectRepository,
    this._taskRepository,
    this._reflectionRepository,
    this._taskLinkRepository,
    this._bus,
  );

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final ReflectionRepository _reflectionRepository;
  final TaskLinkRepository _taskLinkRepository;
  final EventBus _bus;

  @override
  String get operationName => 'TaskReflectOperation';

  @override
  Map<String, dynamic> traceAttributes(TaskReflectCommand command) => {
    'taskId': command.taskId,
    'reflectionType': command.reflectionType,
    'triggerReplan': command.triggerReplan,
  };

  @override
  OperationPolicySet<TaskReflectCommand, TaskReflectFailure>
  preconditionPolicies(
    TaskReflectCommand command,
    OperationContext context,
  ) => const OperationPolicySet([]);

  @override
  Future<Result<TaskReflectResult, TaskReflectFailure>> run(
    TaskReflectCommand command,
  ) async {
    final content = command.content.trim();
    if (content.isEmpty) {
      return const Failure(
        TaskReflectInvalidContent('content cannot be empty'),
      );
    }
    if (command.reflectionBudget <= 0) {
      return Failure(TaskReflectInvalidBudget(command.reflectionBudget));
    }

    final reflectionType = command.reflectionType;
    final source = command.source;

    Task? task;
    if (command.taskId != null) {
      late final TaskId taskId;
      try {
        taskId = command.taskId!;
      } on FormatException {
        return Failure(TaskReflectTaskNotFound(command.taskId!));
      }
      task = await _taskRepository.getById(taskId);
      if (task == null) {
        return Failure(TaskReflectTaskNotFound(command.taskId!));
      }
    }

    final project = task != null
        ? await _projectRepository.getById(task.projectId)
        : await _projectRepository.getCurrentProject();
    if (project == null) {
      return const Failure(TaskReflectProjectNotFound());
    }

    final existingReflections = task != null
        ? await _reflectionRepository.getByTaskId(task.id)
        : (await _reflectionRepository.getByProjectId(
            project.id,
          )).where((reflection) => reflection.taskId == null).toList();
    try {
      ensureReflectionBudgetAvailable(
        existingReflections: existingReflections.length,
        reflectionBudget: command.reflectionBudget,
      );
    } on RecursiveReflectionWarning catch (error) {
      return Failure(TaskReflectBudgetExceeded(error.message));
    }

    final now = DateTime.now().toUtc();

    if (task != null) {
      final updatedTask = task.copyWith(
        lastActionType: .reflection,
        metadata: appendTaskActionHistory(
          task,
          .reflection,
        ),
        updatedAt: now,
      );
      task = await _taskRepository.save(updatedTask);
      await _bus.publish(DomainEvent.taskUpdated(taskId: task.id));
    }

    final reflection = Reflection(
      id: .generate(),
      projectId: project.id,
      taskId: task?.id,
      content: content,
      reflectionType: reflectionType,
      triggeredReplan: command.triggerReplan,
      reflectionBudget: command.reflectionBudget,
      createdAt: now,
      source: source,
    );
    final savedReflection = await _reflectionRepository.save(reflection);

    Task? replanTask;
    if (command.triggerReplan) {
      if (task == null) {
        return const Failure(
          TaskReflectReplanTaskCreateFailed(
            'triggerReplan requires task context',
          ),
        );
      }

      final replan = Task(
        id: .generate(),
        projectId: task.projectId,
        title: .new('Replan based on reflection'),
        status: .pending,
        contextState: .active,
        completionPolicy: .allChildren,
        businessValue: 50,
        urgencyScore: 50,
        lastActionType: .execution,
        lastProgressAt: now,
        createdAt: now,
        updatedAt: now,
        tags: const ['replan'],
        metadata: {
          'reflectionId': savedReflection.id.raw,
          'sourceTaskId': task.id,
        },
        planVersion: 0,
      );

      replanTask = await _taskRepository.save(replan);
      await _taskLinkRepository.save(
        TaskLink(
          id: const Uuid().v7(),
          fromTaskId: task.id,
          toTaskId: replanTask.id,
          linkType: LinkType.soft,
          label: 'reflection_replan:${savedReflection.id.raw}',
          createdAt: now,
        ),
      );
      await _bus.publish(DomainEvent.taskCreated(taskId: replanTask.id));
    }

    return Success(
      TaskReflectResult(
        reflection: savedReflection,
        replanTask: replanTask,
      ),
    );
  }
}
