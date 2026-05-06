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
  late TaskBulkAddOperation taskBulkAdd;
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
    taskBulkAdd = TaskBulkAddOperation(
      pipeline,
      taskRepo,
      projectRepo,
      bus,
    );

    final created = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Bulk Add Project')),
    );
    project = (created as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  test(
    'bulk adds multiple tasks without parent hierarchy',
    () async {
      final result = await taskBulkAdd.execute(
        TaskBulkAddCommand(
          projectId: project.id.value,
          tasks: const [
            TaskBulkAddTaskSpec(title: 'Backend setup'),
            TaskBulkAddTaskSpec(title: 'Frontend setup'),
            TaskBulkAddTaskSpec(title: 'Database schema'),
          ],
        ),
      );

      expect(result.isSuccess, isTrue);
      final value =
          (result as Success<TaskBulkAddResult, TaskBulkAddFailure>).value;
      expect(value.count, 3);
      expect(value.tasks, hasLength(3));
      expect(value.tasks.map((t) => t.title.value), [
        'Backend setup',
        'Frontend setup',
        'Database schema',
      ]);
    },
  );

  test('bulk adds tasks with parent hierarchy', () async {
    // First create a parent task
    final parentResult = await taskCreate.execute(
      TaskCreateCommand(
        projectId: project.id.value,
        title: 'Backend',
      ),
    );

    expect(parentResult.isSuccess, isTrue);
    final parentTask = (parentResult as Success<Task, dynamic>).value;

    // Now bulk add with valid parent
    final bulkResult = await taskBulkAdd.execute(
      TaskBulkAddCommand(
        projectId: project.id.value,
        tasks: [
          TaskBulkAddTaskSpec(
            title: 'API Development',
            parentId: parentTask.id.raw,
          ),
          TaskBulkAddTaskSpec(
            title: 'Database Ops',
            parentId: parentTask.id.raw,
          ),
        ],
      ),
    );

    expect(bulkResult.isSuccess, isTrue);
    final value =
        (bulkResult as Success<TaskBulkAddResult, TaskBulkAddFailure>).value;
    expect(value.count, 2);
    expect(
      value.tasks.every((t) => t.parentId == parentTask.id),
      isTrue,
    );
  });

  test(
    'rejects bulk add with too many tasks',
    () async {
      final tasks = List.generate(
        TaskBulkAddOperation.maxBulkSize + 10,
        (i) => TaskBulkAddTaskSpec(title: 'Task $i'),
      );

      final result = await taskBulkAdd.execute(
        TaskBulkAddCommand(projectId: project.id.value, tasks: tasks),
      );

      expect(result.isFailure, isTrue);
    },
  );

  test(
    'rejects bulk add if project does not exist',
    () async {
      final result = await taskBulkAdd.execute(
        const TaskBulkAddCommand(
          projectId: 'invalid-project-id',
          tasks: [
            TaskBulkAddTaskSpec(title: 'Some Task'),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    },
  );

  test(
    'respects business value and urgency score',
    () async {
      final result = await taskBulkAdd.execute(
        TaskBulkAddCommand(
          projectId: project.id.value,
          tasks: const [
            TaskBulkAddTaskSpec(
              title: 'Custom values',
              businessValue: 75,
              urgencyScore: 80,
            ),
          ],
        ),
      );

      expect(result.isSuccess, isTrue);
      final value =
          (result as Success<TaskBulkAddResult, TaskBulkAddFailure>).value;
      expect(value.tasks.first.businessValue, 75);
      expect(value.tasks.first.urgencyScore, 80);
    },
  );

  test('rejects task with empty title', () async {
    final result = await taskBulkAdd.execute(
      TaskBulkAddCommand(
        projectId: project.id.value,
        tasks: const [
          TaskBulkAddTaskSpec(title: 'Valid'),
          TaskBulkAddTaskSpec(title: '   '),
        ],
      ),
    );

    expect(result.isFailure, isTrue);
    final failure =
        (result as Failure<TaskBulkAddResult, TaskBulkAddFailure>).error;
    expect(failure, isA<TaskBulkAddTaskCreationFailed>());
    expect((failure as TaskBulkAddTaskCreationFailed).taskIndex, 1);
  });

  test('rejects task with unknown contextState', () async {
    final result = await taskBulkAdd.execute(
      TaskBulkAddCommand(
        projectId: project.id.value,
        tasks: const [
          TaskBulkAddTaskSpec(title: 'Ok'),
          TaskBulkAddTaskSpec(title: 'Bad context', contextState: 'invalid'),
        ],
      ),
    );

    expect(result.isFailure, isTrue);
    final failure =
        (result as Failure<TaskBulkAddResult, TaskBulkAddFailure>).error;
    expect(failure, isA<TaskBulkAddTaskCreationFailed>());
    expect((failure as TaskBulkAddTaskCreationFailed).taskIndex, 1);
  });

  test('rejects task with unknown completionPolicy', () async {
    final result = await taskBulkAdd.execute(
      TaskBulkAddCommand(
        projectId: project.id.value,
        tasks: const [
          TaskBulkAddTaskSpec(
            title: 'Bad policy',
            completionPolicy: 'notAPolicy',
          ),
        ],
      ),
    );

    expect(result.isFailure, isTrue);
    final failure =
        (result as Failure<TaskBulkAddResult, TaskBulkAddFailure>).error;
    expect(failure, isA<TaskBulkAddTaskCreationFailed>());
    expect((failure as TaskBulkAddTaskCreationFailed).taskIndex, 0);
  });

  test('rejects task with empty title', () async {
    final result = await taskBulkAdd.execute(
      TaskBulkAddCommand(
        projectId: project.id.value,
        tasks: const [TaskBulkAddTaskSpec(title: '')],
      ),
    );

    expect(result.isFailure, isTrue);
    final failure =
        (result as Failure<TaskBulkAddResult, TaskBulkAddFailure>).error;
    expect(failure, isA<TaskBulkAddTaskCreationFailed>());
    expect((failure as TaskBulkAddTaskCreationFailed).taskIndex, 0);
  });

  test(
    'tasks sharing a parentId are siblings without automatic sibling links',
    () async {
      final parentResult = await taskCreate.execute(
        TaskCreateCommand(
          projectId: project.id.value,
          title: 'Parent',
        ),
      );
      final parent = (parentResult as Success<Task, dynamic>).value;

      final result = await taskBulkAdd.execute(
        TaskBulkAddCommand(
          projectId: project.id.value,
          tasks: [
            TaskBulkAddTaskSpec(title: 'Sibling A', parentId: parent.id.raw),
            TaskBulkAddTaskSpec(title: 'Sibling B', parentId: parent.id.raw),
          ],
        ),
      );

      expect(result.isSuccess, isTrue);
      final created =
          (result as Success<TaskBulkAddResult, TaskBulkAddFailure>).value;
      expect(created.tasks, hasLength(2));

      final sibA = created.tasks.first;
      final sibB = created.tasks.last;

      // No links should exist directly between the two siblings.
      final links = await taskLinkRepo.getAllByProjectLinks([sibA.id, sibB.id]);
      final siblingLinks = links.where(
        (l) =>
            (l.fromTaskId == sibA.id && l.toTaskId == sibB.id) ||
            (l.fromTaskId == sibB.id && l.toTaskId == sibA.id),
      );
      expect(siblingLinks, isEmpty);
    },
  );
}
