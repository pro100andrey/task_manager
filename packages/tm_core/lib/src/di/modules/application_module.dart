// Classes are registered directly via @injectable/@lazySingleton on their own definitions.
import 'package:injectable/injectable.dart';

import '../../domain/queries/project/get_all_projects_query.dart';
import '../../domain/queries/project/get_current_project_query.dart';
import '../../operations/project/project_create_operation.dart';

@module
abstract class ApplicationModule {
  // Operations
  @lazySingleton
  ProjectCreateOperation get projectCreateOperation;

  // Queries
  @LazySingleton()
  GetCurrentProjectQuery get getCurrentProjectQuery;

  @LazySingleton()
  GetAllProjectsQuery get getAllProjectsQuery;
}
