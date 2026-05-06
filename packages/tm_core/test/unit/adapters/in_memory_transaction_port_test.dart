import 'package:test/test.dart';
import 'package:tm_core/src/adapters/repositories/mem_projects_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_task_links_repository_impl.dart';
import 'package:tm_core/src/adapters/repositories/mem_tasks_repository_impl.dart';
import 'package:tm_core/src/adapters/transaction/in_memory_transaction_port_impl.dart';
import 'package:tm_core/src/domain/entities/project.dart';
import 'package:tm_core/src/domain/entities/task.dart';
import 'package:tm_core/src/domain/entities/task_link.dart';
import 'package:tm_core/src/domain/enums/link_type.dart';
import 'package:tm_core/src/domain/enums/task_completion_policy.dart';
import 'package:tm_core/src/domain/enums/task_context_state.dart';
import 'package:tm_core/src/domain/enums/task_last_action_type.dart';
import 'package:tm_core/src/domain/enums/task_status.dart';
import 'package:tm_core/src/domain/result.dart';
import 'package:tm_core/src/domain/value_objects/project/project_id.dart';
import 'package:tm_core/src/domain/value_objects/project/project_name.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';
import 'package:tm_core/src/domain/value_objects/task/task_title.dart';

void main() {
  late MemProjectsRepositoryImpl projectRepo;
  late MemTasksRepositoryImpl taskRepo;
  late MemTaskLinkRepositoryImpl taskLinkRepo;
  late InMemoryTransactionPortImpl transactionPort;

  setUp(() {
    projectRepo = MemProjectsRepositoryImpl();
    taskRepo = MemTasksRepositoryImpl();
    taskLinkRepo = MemTaskLinkRepositoryImpl();
    transactionPort = InMemoryTransactionPortImpl([
      projectRepo,
      taskRepo,
      taskLinkRepo,
    ]);
  });

  test('rolls back repository state when action throws', () async {
    final now = DateTime.now().toUtc();
    final project = Project(
      id: ProjectId.generate(),
      name: const ProjectName('Rollback Project'),
      createdAt: now,
    );
    await projectRepo.save(project);

    final task = Task(
      id: TaskId.generate(),
      projectId: project.id,
      title: TaskTitle('Original task'),
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
    );
    await taskRepo.save(task);

    var threw = false;
    try {
      await transactionPort.run(() async {
        await projectRepo.switchCurrentProject(project.id);
        await taskRepo.delete(task.id);
        await taskLinkRepo.save(
          TaskLink(
            id: 'temp-link',
            fromTaskId: task.id,
            toTaskId: TaskId.generate(),
            linkType: LinkType.soft,
            createdAt: now,
          ),
        );
        throw Exception('boom');
      });
    } on Exception catch (error) {
      threw = true;
      expect(error.toString(), contains('boom'));
    }

    expect(threw, isTrue);

    expect(await projectRepo.getCurrentProject(), isNull);
    expect(await taskRepo.getById(task.id), isNotNull);
    expect(await taskLinkRepo.getByTaskId(task.id), isEmpty);
  });

  test('keeps state changes when action succeeds', () async {
    final now = DateTime.now().toUtc();
    final project = Project(
      id: ProjectId.generate(),
      name: const ProjectName('Commit Project'),
      createdAt: now,
    );
    await projectRepo.save(project);

    await transactionPort.run(() async {
      await projectRepo.switchCurrentProject(project.id);
    });

    expect((await projectRepo.getCurrentProject())?.id, project.id);
  });

  test('rolls back repository state when action returns Failure', () async {
    final now = DateTime.now().toUtc();
    final project = Project(
      id: ProjectId.generate(),
      name: const ProjectName('Failure Project'),
      createdAt: now,
    );
    await projectRepo.save(project);

    final result = await transactionPort.run<Result<void, String>>(() async {
      await projectRepo.switchCurrentProject(project.id);
      return const Failure('failed');
    });

    expect(result.isFailure, isTrue);
    expect(await projectRepo.getCurrentProject(), isNull);
  });
}
