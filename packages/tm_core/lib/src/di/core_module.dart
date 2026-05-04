import 'package:injectable/injectable.dart';

import '../application/ports/domain_event_bus.dart';
import '../application/ports/no_op_transaction_port.dart';
import '../application/ports/tracing_port.dart';
import '../application/ports/transaction_port.dart';
import '../application/repositories/project_repository.dart';
import '../infra/events/ordered_domain_bus_impl.dart';
import '../infra/repositories/mem_projects_repository_impl.dart';
import '../infra/tracing/logging_tracing_port.dart';

@module
abstract class CoreModule {
  @LazySingleton(as: ProjectRepository)
  MemProjectsRepositoryImpl get projectsRepository;

  @LazySingleton(as: TransactionPort)
  NoOpTransactionPort get noOpTransactionPort;

  @LazySingleton(as: DomainEventBus)
  OrderedDomainEventBusImpl get domainEventBus;

  @LazySingleton(as: TracingPort)
  LoggingTracingPort get tracingPort;
}
