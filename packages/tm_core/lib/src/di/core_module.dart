import 'dart:io';

import 'package:injectable/injectable.dart';

import '../adapters/behaviors/tracing_behavior.dart';
import '../adapters/behaviors/transaction_behavior.dart';
import '../adapters/events/ordered_domain_event_bus_impl.dart';
import '../adapters/repositories/mem_knowledge_repository_impl.dart';
import '../adapters/repositories/mem_projects_repository_impl.dart';
import '../adapters/repositories/mem_reflection_repository_impl.dart';
import '../adapters/repositories/mem_task_knowledge_ref_repository_impl.dart';
import '../adapters/repositories/mem_task_links_repository_impl.dart';
import '../adapters/repositories/mem_tasks_repository_impl.dart';
import '../adapters/tracing/logging_tracing_port_impl.dart';
import '../adapters/tracing/tracing_logging_config.dart';
import '../adapters/transaction/in_memory_snapshot_store.dart';
import '../adapters/transaction/in_memory_transaction_port_impl.dart';
import '../adapters/transaction/no_op_transaction_port_impl.dart';
import '../application/operations/operation_pipeline.dart';
import '../application/ports/domain_event_bus.dart';
import '../application/ports/knowledge_repository.dart';
import '../application/ports/project_repository.dart';
import '../application/ports/reflection_repository.dart';
import '../application/ports/task_knowledge_ref_repository.dart';
import '../application/ports/task_link_repository.dart';
import '../application/ports/task_repository.dart';
import '../application/ports/tracing_port.dart';
import '../application/ports/transaction_port.dart';

@module
abstract class CoreModule {
  @LazySingleton(as: ProjectRepository)
  MemProjectsRepositoryImpl get projectsRepository;

  @LazySingleton(as: TaskRepository)
  MemTasksRepositoryImpl get tasksRepository;

  @LazySingleton(as: KnowledgeRepository)
  MemKnowledgeRepositoryImpl get knowledgeRepository;

  @LazySingleton(as: ReflectionRepository)
  MemReflectionRepositoryImpl get reflectionRepository;

  @LazySingleton(as: TaskKnowledgeRefRepository)
  MemTaskKnowledgeRefRepositoryImpl get taskKnowledgeRefRepository;

  @LazySingleton(as: TaskLinkRepository)
  MemTaskLinkRepositoryImpl get taskLinkRepository;

  @lazySingleton
  NoOpTransactionPortImpl get noOpTransactionPort;

  @LazySingleton(as: TransactionPort)
  InMemoryTransactionPortImpl transactionPort(
    ProjectRepository projectsRepository,
    TaskRepository tasksRepository,
    TaskLinkRepository taskLinkRepository,
    KnowledgeRepository knowledgeRepository,
    TaskKnowledgeRefRepository taskKnowledgeRefRepository,
    ReflectionRepository reflectionRepository,
  ) => InMemoryTransactionPortImpl([
    projectsRepository as InMemorySnapshotStore,
    tasksRepository as InMemorySnapshotStore,
    taskLinkRepository as InMemorySnapshotStore,
    knowledgeRepository as InMemorySnapshotStore,
    taskKnowledgeRefRepository as InMemorySnapshotStore,
    reflectionRepository as InMemorySnapshotStore,
  ]);

  @LazySingleton(as: DomainEventBus)
  OrderedDomainEventBusImpl get domainEventBus;

  @LazySingleton(as: TracingPort)
  LoggingTracingPortImpl get tracingPort;

  @LazySingleton()
  TracingLoggingConfig get tracingLoggingConfig => TracingLoggingConfig(
    rootLevel: .ALL,
    loggerName: 'tm_core',
    onRecord: (record) => stdout.writeln(
      '[${record.level.name}] ${record.loggerName}: ${record.message}',
    ),
  );

  @lazySingleton
  OperationPipeline operationPipeline(
    TracingPort tracing,
    TransactionPort transaction,
  ) => OperationPipeline([
    TracingBehavior(tracing),
    TransactionBehavior(transaction),
  ]);
}
