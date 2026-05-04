import 'package:injectable/injectable.dart';

import '../application/ports/no_op_transaction_port.dart';
import '../application/ports/transaction_port.dart';
import '../application/repositories/project_repository.dart';
import '../infra/repositories/mem_projects_repository_impl.dart';

@module
abstract class CoreModule {
  @LazySingleton(as: ProjectRepository)
  MemProjectsRepositoryImpl get projectsRepository =>
      MemProjectsRepositoryImpl();

  @LazySingleton(as: TransactionPort)
  NoOpTransactionPort get noOpTransactionPort => NoOpTransactionPort();
}
