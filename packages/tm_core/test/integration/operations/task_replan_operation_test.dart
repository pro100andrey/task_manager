import 'package:test/test.dart';
import 'package:tm_core/src/adapters/behaviors/tracing_behavior.dart';
import 'package:tm_core/src/adapters/behaviors/transaction_behavior.dart';
import 'package:tm_core/src/adapters/events/domain_event_bus_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_tasks_repository_impl.dart';
import 'package:tm_core/src/adapters/tracing/logging_tracing_port_impl.dart';
import 'package:tm_core/src/adapters/transaction/in_memory_transaction_port_impl.dart';
import 'package:tm_core/tm_core.dart';

void main() {
  late DomainEventBusImpl bus;
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late MemTaskLinkRepositoryImpl taskLinkRepo;
  late OperationPipeline pipeline;
  late ProjectCreateOperation projectCreate;
  late TaskCreateOperation taskCreate;
  late TaskReplanOperation taskReplan;
  late TaskStartOperation taskStart;
  late TaskReflectOperation taskReflect;
  late Project project;

  setUp(() async {
    bus = DomainEventBusImpl();
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    taskLinkRepo = MemTaskLinkRepositoryImpl();
    pipeline = OperationPipeline([
      TracingBehavior(LoggingTracingPortImpl(config: const .new())),
      TransactionBehavior(
        InMemoryTransactionPortImpl([projectRepo, taskRepo, taskLinkRepo]),
      ),
    ]);

    projectCreate = ProjectCreateOperation(pipeline, projectRepo, bus);
    taskCreate = TaskCreateOperation(pipeline, taskRepo, projectRepo, bus);
    taskReplan = TaskReplanOperation(pipeline, taskRepo, taskLinkRepo, bus);
    taskStart = TaskStartOperation(pipeline, taskRepo, bus);
    taskReflect = TaskReflectOperation(
      pipeline,
      projectRepo,
      taskRepo,
      MemReflectionRepositoryImpl(),
      taskLinkRepo,
      bus,
    );

    final created = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Replan Project')),
    );
    project = (created as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title, {TaskId? parentId}) async {
    final result = await taskCreate.execute(
      TaskCreateCommand(
        projectId: project.id,
        title: title,
        parentId: parentId,
      ),
    );
    return (result as Success<Task, dynamic>).value;
  }

  Future<void> resetActionHistoryToExecution(Task task) async {
    await taskRepo.save(
      task.copyWith(
        lastActionType: TaskLastActionType.execution,
        metadata: {
          ...task.metadata,
          'actionHistory': [TaskLastActionType.execution.value],
        },
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  test(
    'applies replan changes atomically and increments planVersion',
    () async {
      final root = await createTask('Root');
      final child = await createTask('Child', parentId: root.id);

      final result = await taskReplan.execute(
        TaskReplanCommand(
          taskId: root.id,
          changes: [
            ReplanChange(
              action: .updateTask,
              params: {'taskId': child.id, 'title': 'Child updated'},
            ),
            ReplanChange(
              action: .setContext,
              params: {'taskId': child.id, 'contextState': 'backlog'},
            ),
            const ReplanChange(
              action: .addTask,
              params: {'title': 'New subtask'},
            ),
          ],
        ),
      );

      expect(result.isSuccess, isTrue);
      final value =
          (result as Success<TaskReplanResult, TaskReplanFailure>).value;
      expect(value.applied, hasLength(3));
      expect(value.planVersion, 1);

      final updatedRoot = await taskRepo.getById(root.id);
      final updatedChild = await taskRepo.getById(child.id);
      final projectTasks = await taskRepo.getByProjectId(project.id);

      expect(updatedRoot!.lastActionType, TaskLastActionType.planning);
      expect(updatedChild!.title.value, 'Child updated');
      expect(updatedChild.contextState, TaskContextState.backlog);
      expect(projectTasks, hasLength(3));
    },
  );

  test('rolls back all changes when one replan step fails', () async {
    final root = await createTask('Root');
    final child = await createTask('Child', parentId: root.id);

    final result = await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: [
          ReplanChange(
            action: .updateTask,
            params: {'taskId': child.id, 'title': 'Changed before fail'},
          ),
          const ReplanChange(
            action: .addTask,
            params: {'taskId': 'bad-id', 'contextState': 'backlog'},
          ),
        ],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(
      (result as Failure<TaskReplanResult, TaskReplanFailure>).error,
      isA<TaskReplanValidationError>(),
    );

    final unchangedChild = await taskRepo.getById(child.id);
    final unchangedRoot = await taskRepo.getById(root.id);
    expect(unchangedChild!.title.value, 'Child');
    expect(unchangedRoot!.planVersion, 0);
  });

  test('rejects strong-link cycles during replan', () async {
    final root = await createTask('Root');
    final a = await createTask('A');
    final b = await createTask('B');

    await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: [
          ReplanChange(
            action: .addLink,
            params: {
              'fromTaskId': a.id,
              'toTaskId': b.id,
              'linkType': 'strong',
            },
          ),
        ],
      ),
    );

    final cycleResult = await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: [
          ReplanChange(
            action: .addLink,
            params: {
              'fromTaskId': b.id,
              'toTaskId': a.id,
              'linkType': 'strong',
            },
          ),
        ],
      ),
    );

    expect(cycleResult.isFailure, isTrue);
    expect(
      (cycleResult as Failure<TaskReplanResult, TaskReplanFailure>).error,
      isA<TaskReplanCycleDetected>(),
    );
  });

  test('blocks replan after three planning or reflection actions', () async {
    final root = await createTask('Root');

    await taskReflect.execute(
      TaskReflectCommand(taskId: root.id, content: 'First reflection'),
    );
    await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: const [
          ReplanChange(action: .addTask, params: {'title': 'A'}),
        ],
      ),
    );
    await taskReflect.execute(
      TaskReflectCommand(taskId: root.id, content: 'Second reflection'),
    );

    final blocked = await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: const [
          ReplanChange(action: .addTask, params: {'title': 'B'}),
        ],
      ),
    );

    expect(blocked.isFailure, isTrue);
    expect(
      (blocked as Failure<TaskReplanResult, TaskReplanFailure>).error,
      isA<TaskReplanStallDetected>(),
    );
  });

  test('allows replan again after execution resets action history', () async {
    final root = await createTask('Root');

    await taskReflect.execute(
      TaskReflectCommand(taskId: root.id, content: 'First reflection'),
    );
    await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: const [
          ReplanChange(action: .addTask, params: {'title': 'A'}),
        ],
      ),
    );

    await taskStart.execute(TaskStartCommand(taskId: root.id));

    final allowed = await taskReplan.execute(
      TaskReplanCommand(
        taskId: root.id,
        changes: const [
          ReplanChange(action: .addTask, params: {'title': 'B'}),
        ],
      ),
    );

    expect(allowed.isSuccess, isTrue);
  });

  test(
    'blocks replan when created/completed ratio falls below threshold',
    () async {
      final root = await createTask('Root');

      for (var index = 0; index < 6; index++) {
        final result = await taskReplan.execute(
          TaskReplanCommand(
            taskId: root.id,
            changes: [
              ReplanChange(
                action: .addTask,
                params: {'title': 'Added $index'},
              ),
            ],
          ),
        );
        expect(result.isSuccess, isTrue);

        final savedRoot = await taskRepo.getById(root.id);
        await resetActionHistoryToExecution(savedRoot!);
      }

      final blocked = await taskReplan.execute(
        TaskReplanCommand(
          taskId: root.id,
          changes: const [
            ReplanChange(action: .addTask, params: {'title': 'Blocked'}),
          ],
        ),
      );

      expect(blocked.isFailure, isTrue);
      expect(
        (blocked as Failure<TaskReplanResult, TaskReplanFailure>).error,
        isA<TaskReplanStallDetected>(),
      );
    },
  );

  test(
    'allows replan when completion ratio recovers above threshold',
    () async {
      final root = await createTask('Root');

      for (var index = 0; index < 6; index++) {
        final result = await taskReplan.execute(
          TaskReplanCommand(
            taskId: root.id,
            changes: [
              ReplanChange(
                action: .addTask,
                params: {'title': 'Added $index'},
              ),
            ],
          ),
        );
        expect(result.isSuccess, isTrue);

        final savedRoot = await taskRepo.getById(root.id);
        await resetActionHistoryToExecution(savedRoot!);
      }

      final projectTasks = await taskRepo.getByProjectId(project.id);
      final child = projectTasks.firstWhere((task) => task.parentId == root.id);
      await taskStart.execute(TaskStartCommand(taskId: child.id));
      final done = await TaskDoneOperation(pipeline, taskRepo, bus).execute(
        TaskDoneCommand(taskId: child.id),
      );
      expect(done.isSuccess, isTrue);

      final savedRoot = await taskRepo.getById(root.id);
      final windows = taskPnrWindows(savedRoot!);
      expect(windows.fold<int>(0, (sum, window) => sum + window.completed), 1);
      await resetActionHistoryToExecution(savedRoot);

      final allowed = await taskReplan.execute(
        TaskReplanCommand(
          taskId: root.id,
          changes: const [
            ReplanChange(action: .addTask, params: {'title': 'Allowed'}),
          ],
        ),
      );

      expect(allowed.isSuccess, isTrue);
    },
  );
}
