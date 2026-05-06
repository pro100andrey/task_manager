// Classes are registered directly via @injectable/@lazySingleton on their own definitions.
import 'package:injectable/injectable.dart';

import '../../application/operations/knowledge/kg_entity_add_operation.dart';
import '../../application/operations/knowledge/kg_entity_update_operation.dart';
import '../../application/operations/knowledge/kg_task_link_operation.dart';
import '../../application/operations/project/project_change_description_operation.dart';
import '../../application/operations/project/project_create_operation.dart';
import '../../application/operations/project/project_delete_operation.dart';
import '../../application/operations/project/project_rename_operation.dart';
import '../../application/operations/project/project_switch_operation.dart';
import '../../application/operations/project/project_update_operation.dart';
import '../../application/operations/reflection/task_reflect_operation.dart';
import '../../application/operations/task/task_cancel_operation.dart';
import '../../application/operations/task/task_create_operation.dart';
import '../../application/operations/task/task_delete_operation.dart';
import '../../application/operations/task/task_done_operation.dart';
import '../../application/operations/task/task_fail_operation.dart';
import '../../application/operations/task/task_hold_operation.dart';
import '../../application/operations/task/task_move_operation.dart';
import '../../application/operations/task/task_rename_alias_operation.dart';
import '../../application/operations/task/task_set_context_operation.dart';
import '../../application/operations/task/task_start_operation.dart';
import '../../application/operations/task/task_update_operation.dart';
import '../../application/operations/task_link/task_link_add_operation.dart';
import '../../application/operations/task_link/task_link_remove_operation.dart';
import '../../application/queries/knowledge/get_knowledge_entities_query.dart';
import '../../application/queries/knowledge/get_knowledge_entity_query.dart';
import '../../application/queries/knowledge/get_task_knowledge_entities_query.dart';
import '../../application/queries/project/get_all_projects_query.dart';
import '../../application/queries/project/get_current_project_query.dart';
import '../../application/queries/reflection/reflection_list_query.dart';
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

  @lazySingleton
  TaskUpdateOperation get taskUpdateOperation;

  @lazySingleton
  TaskSetContextOperation get taskSetContextOperation;

  @lazySingleton
  TaskMoveOperation get taskMoveOperation;

  @lazySingleton
  TaskRenameAliasOperation get taskRenameAliasOperation;

  // TaskLink Operations
  @lazySingleton
  TaskLinkAddOperation get taskLinkAddOperation;

  @lazySingleton
  TaskLinkRemoveOperation get taskLinkRemoveOperation;

  // Knowledge Operations
  @lazySingleton
  KgEntityAddOperation get kgEntityAddOperation;

  @lazySingleton
  KgEntityUpdateOperation get kgEntityUpdateOperation;

  @lazySingleton
  KgTaskLinkOperation get kgTaskLinkOperation;

  // Reflection Operations
  @lazySingleton
  TaskReflectOperation get taskReflectOperation;

  // Project Queries
  @LazySingleton()
  GetCurrentProjectQuery get getCurrentProjectQuery;

  @LazySingleton()
  GetAllProjectsQuery get getAllProjectsQuery;

  // Task Queries
  @lazySingleton
  GetActiveFrontQuery get getActiveFrontQuery;

  // Knowledge Queries
  @lazySingleton
  GetKnowledgeEntitiesQuery get getKnowledgeEntitiesQuery;

  @lazySingleton
  GetKnowledgeEntityQuery get getKnowledgeEntityQuery;

  @lazySingleton
  GetTaskKnowledgeEntitiesQuery get getTaskKnowledgeEntitiesQuery;

  // Reflection Queries
  @lazySingleton
  ReflectionListQuery get reflectionListQuery;
}
