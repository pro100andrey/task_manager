import 'package:injectable/injectable.dart';

import '../adapters/behaviors/tracing_behavior.dart';
import '../adapters/behaviors/transaction_behavior.dart';
import '../adapters/events/ordered_domain_event_bus_impl.dart';
import '../adapters/repositories/mem_projects_repository_impl.dart';
import '../adapters/repositories/mem_task_links_repository_impl.dart';
import '../adapters/repositories/mem_tasks_repository_impl.dart';
import '../adapters/tracing/logging_tracing_port_impl.dart';
import '../adapters/transaction/no_op_transaction_port_impl.dart';
import '../application/operations/operation_pipeline.dart';
import '../application/ports/domain_event_bus.dart';
import '../application/ports/project_repository.dart';
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

  @LazySingleton(as: TaskLinkRepository)
  MemTaskLinkRepositoryImpl get taskLinkRepository;

  @LazySingleton(as: TransactionPort)
  NoOpTransactionPortImpl get noOpTransactionPort;

  @LazySingleton(as: DomainEventBus)
  OrderedDomainEventBusImpl get domainEventBus;

  @LazySingleton(as: TracingPort)
  LoggingTracingPortImpl get tracingPort;

  @lazySingleton
  OperationPipeline operationPipeline(
    TracingPort tracing,
    TransactionPort transaction,
  ) => OperationPipeline([
    TracingBehavior(tracing),
    TransactionBehavior(transaction),
  ]);
}
