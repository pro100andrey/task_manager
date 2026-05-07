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
  late TaskBreakdownOperation taskBreakdown;
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
    taskBreakdown = TaskBreakdownOperation(
      pipeline,
      taskRepo,
      taskLinkRepo,
      bus,
    );

    final created = await projectCreate.execute(
      const ProjectCreateCommand(name: .new('Breakdown Project')),
    );
    project = (created as Success<Project, dynamic>).value;
  });

  tearDown(() => bus.dispose());

  Future<Task> createTask(String title) async {
    final result = await taskCreate.execute(
      TaskCreateCommand(projectId: project.id, title: title),
    );
    return (result as Success<Task, dynamic>).value;
  }

  test(
    'creates child tasks in parallel mode and increments planVersion',
    () async {
      final root = await createTask('Root');

      final result = await taskBreakdown.execute(
        const TaskBreakdownCommand(
          taskId: 'placeholder',
          subtasks: [
            TaskBreakdownSubtask(title: 'Design schema'),
            TaskBreakdownSubtask(title: 'Implement JWT'),
            TaskBreakdownSubtask(title: 'Write tests'),
          ],
        ),
      );

      expect(result.isFailure, isTrue);

      final success = await taskBreakdown.execute(
        TaskBreakdownCommand(
          taskId: root.id,
          subtasks: const [
            TaskBreakdownSubtask(title: 'Design schema'),
            TaskBreakdownSubtask(title: 'Implement JWT'),
            TaskBreakdownSubtask(title: 'Write tests'),
          ],
        ),
      );

      expect(success.isSuccess, isTrue);
      final value =
          (success as Success<TaskBreakdownResult, TaskBreakdownFailure>).value;
      expect(value.subtasks, hasLength(3));
      expect(value.links, isEmpty);
      expect(value.planVersion, 1);
      expect(value.subtasks.every((task) => task.parentId == root.id), isTrue);
    },
  );

  test('creates strong chain in sequence mode', () async {
    final root = await createTask('Root');

    final result = await taskBreakdown.execute(
      TaskBreakdownCommand(
        taskId: root.id,
        mode: 'sequence',
        subtasks: const [
          TaskBreakdownSubtask(title: 'Step 1'),
          TaskBreakdownSubtask(title: 'Step 2'),
          TaskBreakdownSubtask(title: 'Step 3'),
        ],
      ),
    );

    expect(result.isSuccess, isTrue);
    final value =
        (result as Success<TaskBreakdownResult, TaskBreakdownFailure>).value;
    expect(value.subtasks, hasLength(3));
    expect(value.links, hasLength(2));
    expect(
      value.links.every((link) => link.linkType == LinkType.strong),
      isTrue,
    );
    expect(value.links.first.fromTaskId, value.subtasks[0].id);
    expect(value.links.first.toTaskId, value.subtasks[1].id);
  });

  test('rolls back breakdown when one subtask is invalid', () async {
    final root = await createTask('Root');

    final result = await taskBreakdown.execute(
      TaskBreakdownCommand(
        taskId: root.id,
        subtasks: const [
          TaskBreakdownSubtask(title: 'Valid'),
          TaskBreakdownSubtask(title: ''),
        ],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(
      (result as Failure<TaskBreakdownResult, TaskBreakdownFailure>).error,
      isA<TaskBreakdownValidationError>(),
    );

    final projectTasks = await taskRepo.getByProjectId(project.id);
    expect(projectTasks, hasLength(1));
    expect(projectTasks.single.id, root.id);
  });
}
