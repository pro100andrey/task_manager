// Classes are registered directly via @injectable/@lazySingleton on their own definitions.
import 'package:injectable/injectable.dart';

@module
abstract class ApplicationModule {
  // @lazySingleton
  // ProjectCreateOperation projectCreateOperation(
  //   TransactionPort tx,
  //   ProjectRepository repo,
  //   DomainEventBus eventBus,
  //   TracingPort tracer,
  // );

  // @lazySingleton
  // GetCurrentProjectQuery getCurrentProjectQuery(ProjectRepository repo);

  // @lazySingleton
  // GetAllProjectsQuery getAllProjectsQuery(ProjectRepository repo);
}
