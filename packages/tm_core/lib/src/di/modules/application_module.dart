// Classes are registered directly via @injectable/@lazySingleton on their own definitions.
import 'package:injectable/injectable.dart';

import '../../application/operations/project/project_create_operation.dart';
import '../../application/queries/project/get_all_projects_query.dart';
import '../../application/queries/project/get_current_project_query.dart';

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
