// Classes are registered directly via @injectable/@lazySingleton on their own definitions.
import 'package:injectable/injectable.dart';

import '../../application/operations/project/project_change_description_operation.dart';
import '../../application/operations/project/project_create_operation.dart';
import '../../application/operations/project/project_delete_operation.dart';
import '../../application/operations/project/project_rename_operation.dart';
import '../../application/operations/project/project_switch_operation.dart';
import '../../application/operations/project/project_update_operation.dart';
import '../../application/operations/task/task_cancel_operation.dart';
import '../../application/operations/task/task_create_operation.dart';
import '../../application/operations/task/task_delete_operation.dart';
import '../../application/operations/task/task_done_operation.dart';
import '../../application/operations/task/task_fail_operation.dart';
import '../../application/operations/task/task_hold_operation.dart';
import '../../application/operations/task/task_start_operation.dart';
import '../../application/operations/task_link/task_link_add_operation.dart';
import '../../application/operations/task_link/task_link_remove_operation.dart';
import '../../application/queries/project/get_all_projects_query.dart';
import '../../application/queries/project/get_current_project_query.dart';
import '../../application/queries/task/get_active_front_query.dart';

@module
abstract class ApplicationModule {
  // Project Operations
  @lazySingleton
  ProjectCreateOperation get projectCreateOperation;

  @lazySingleton
  ProjectRenameOperation get projectRenameOperation;

  @lazySingleton
  ProjectChangeDescriptionOperation get projectChangeDescriptionOperation;

  @lazySingleton
  ProjectUpdateOperation get projectUpdateOperation;

  @lazySingleton
  ProjectDeleteOperation get projectDeleteOperation;

  @lazySingleton
  ProjectSwitchOperation get projectSwitchOperation;

  // Task Operations
  @lazySingleton
  TaskCreateOperation get taskCreateOperation;

  @lazySingleton
  TaskStartOperation get taskStartOperation;

  @lazySingleton
  TaskDoneOperation get taskDoneOperation;

  @lazySingleton
  TaskFailOperation get taskFailOperation;

  @lazySingleton
  TaskCancelOperation get taskCancelOperation;

  @lazySingleton
  TaskHoldOperation get taskHoldOperation;

  @lazySingleton
  TaskDeleteOperation get taskDeleteOperation;

  // TaskLink Operations
  @lazySingleton
  TaskLinkAddOperation get taskLinkAddOperation;

  @lazySingleton
  TaskLinkRemoveOperation get taskLinkRemoveOperation;

  // Project Queries
  @LazySingleton()
  GetCurrentProjectQuery get getCurrentProjectQuery;

  @LazySingleton()
  GetAllProjectsQuery get getAllProjectsQuery;

  // Task Queries
  @lazySingleton
  GetActiveFrontQuery get getActiveFrontQuery;
}
