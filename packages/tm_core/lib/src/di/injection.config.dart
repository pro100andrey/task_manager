// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../adapters/events/ordered_domain_event_bus_impl.dart' as _i1027;
import '../adapters/repositories/mem_projects_repository_impl.dart' as _i949;
import '../adapters/repositories/mem_task_links_repository_impl.dart' as _i565;
import '../adapters/repositories/mem_tasks_repository_impl.dart' as _i425;
import '../adapters/tracing/logging_tracing_port_impl.dart' as _i629;
import '../adapters/tracing/tracing_logging_config.dart' as _i300;
import '../adapters/transaction/no_op_transaction_port_impl.dart' as _i1016;
import '../application/operations/operation_pipeline.dart' as _i840;
import '../application/operations/project/project_change_description_operation.dart'
    as _i789;
import '../application/operations/project/project_create_operation.dart'
    as _i797;
import '../application/operations/project/project_delete_operation.dart'
    as _i460;
import '../application/operations/project/project_rename_operation.dart'
    as _i480;
import '../application/operations/project/project_switch_operation.dart'
    as _i533;
import '../application/operations/project/project_update_operation.dart'
    as _i406;
import '../application/operations/task/task_cancel_operation.dart' as _i781;
import '../application/operations/task/task_create_operation.dart' as _i703;
import '../application/operations/task/task_delete_operation.dart' as _i96;
import '../application/operations/task/task_done_operation.dart' as _i841;
import '../application/operations/task/task_fail_operation.dart' as _i545;
import '../application/operations/task/task_hold_operation.dart' as _i906;
import '../application/operations/task/task_start_operation.dart' as _i74;
import '../application/operations/task_link/task_link_add_operation.dart'
    as _i309;
import '../application/operations/task_link/task_link_remove_operation.dart'
    as _i775;
import '../application/ports/domain_event_bus.dart' as _i512;
import '../application/ports/project_repository.dart' as _i102;
import '../application/ports/task_link_repository.dart' as _i541;
import '../application/ports/task_repository.dart' as _i159;
import '../application/ports/tracing_port.dart' as _i969;
import '../application/ports/transaction_port.dart' as _i1007;
import '../application/queries/project/get_all_projects_query.dart' as _i676;
import '../application/queries/project/get_current_project_query.dart' as _i775;
import 'core_module.dart' as _i154;
import 'modules/application_module.dart' as _i705;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initTmCore(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final coreModule = _$CoreModule(getIt);
  final applicationModule = _$ApplicationModule(getIt);
  gh.lazySingleton<_i159.TaskRepository>(() => coreModule.tasksRepository);
  gh.lazySingleton<_i541.TaskLinkRepository>(
    () => coreModule.taskLinkRepository,
  );
  gh.lazySingleton<_i1007.TransactionPort>(
    () => coreModule.noOpTransactionPort,
  );
  gh.lazySingleton<_i969.TracingPort>(() => coreModule.tracingPort);
  gh.lazySingleton<_i102.ProjectRepository>(
    () => coreModule.projectsRepository,
  );
  gh.lazySingleton<_i512.DomainEventBus>(() => coreModule.domainEventBus);
  gh.lazySingleton<_i840.OperationPipeline>(
    () => coreModule.operationPipeline(
      gh<_i969.TracingPort>(),
      gh<_i1007.TransactionPort>(),
    ),
  );
  gh.lazySingleton<_i775.TaskLinkRemoveOperation>(
    () => applicationModule.taskLinkRemoveOperation,
  );
  gh.lazySingleton<_i703.TaskCreateOperation>(
    () => applicationModule.taskCreateOperation,
  );
  gh.lazySingleton<_i797.ProjectCreateOperation>(
    () => applicationModule.projectCreateOperation,
  );
  gh.lazySingleton<_i480.ProjectRenameOperation>(
    () => applicationModule.projectRenameOperation,
  );
  gh.lazySingleton<_i789.ProjectChangeDescriptionOperation>(
    () => applicationModule.projectChangeDescriptionOperation,
  );
  gh.lazySingleton<_i460.ProjectDeleteOperation>(
    () => applicationModule.projectDeleteOperation,
  );
  gh.lazySingleton<_i533.ProjectSwitchOperation>(
    () => applicationModule.projectSwitchOperation,
  );
  gh.lazySingleton<_i309.TaskLinkAddOperation>(
    () => applicationModule.taskLinkAddOperation,
  );
  gh.lazySingleton<_i775.GetCurrentProjectQuery>(
    () => applicationModule.getCurrentProjectQuery,
  );
  gh.lazySingleton<_i676.GetAllProjectsQuery>(
    () => applicationModule.getAllProjectsQuery,
  );
  gh.lazySingleton<_i74.TaskStartOperation>(
    () => applicationModule.taskStartOperation,
  );
  gh.lazySingleton<_i841.TaskDoneOperation>(
    () => applicationModule.taskDoneOperation,
  );
  gh.lazySingleton<_i545.TaskFailOperation>(
    () => applicationModule.taskFailOperation,
  );
  gh.lazySingleton<_i781.TaskCancelOperation>(
    () => applicationModule.taskCancelOperation,
  );
  gh.lazySingleton<_i906.TaskHoldOperation>(
    () => applicationModule.taskHoldOperation,
  );
  gh.lazySingleton<_i96.TaskDeleteOperation>(
    () => applicationModule.taskDeleteOperation,
  );
  gh.lazySingleton<_i406.ProjectUpdateOperation>(
    () => applicationModule.projectUpdateOperation,
  );
  return getIt;
}

class _$CoreModule extends _i154.CoreModule {
  _$CoreModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i425.MemTasksRepositoryImpl get tasksRepository =>
      _i425.MemTasksRepositoryImpl();

  @override
  _i565.MemTaskLinkRepositoryImpl get taskLinkRepository =>
      _i565.MemTaskLinkRepositoryImpl();

  @override
  _i1016.NoOpTransactionPortImpl get noOpTransactionPort =>
      _i1016.NoOpTransactionPortImpl();

  @override
  _i629.LoggingTracingPortImpl get tracingPort => _i629.LoggingTracingPortImpl(
    config: _getIt<_i300.TracingLoggingConfig>(),
  );

  @override
  _i949.MemProjectsRepositoryImpl get projectsRepository =>
      _i949.MemProjectsRepositoryImpl();

  @override
  _i1027.OrderedDomainEventBusImpl get domainEventBus =>
      _i1027.OrderedDomainEventBusImpl();
}

class _$ApplicationModule extends _i705.ApplicationModule {
  _$ApplicationModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i775.TaskLinkRemoveOperation get taskLinkRemoveOperation =>
      _i775.TaskLinkRemoveOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i541.TaskLinkRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i703.TaskCreateOperation get taskCreateOperation =>
      _i703.TaskCreateOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i159.TaskRepository>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i797.ProjectCreateOperation get projectCreateOperation =>
      _i797.ProjectCreateOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i480.ProjectRenameOperation get projectRenameOperation =>
      _i480.ProjectRenameOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i789.ProjectChangeDescriptionOperation
  get projectChangeDescriptionOperation =>
      _i789.ProjectChangeDescriptionOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i460.ProjectDeleteOperation get projectDeleteOperation =>
      _i460.ProjectDeleteOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i533.ProjectSwitchOperation get projectSwitchOperation =>
      _i533.ProjectSwitchOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i309.TaskLinkAddOperation get taskLinkAddOperation =>
      _i309.TaskLinkAddOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i159.TaskRepository>(),
        _getIt<_i541.TaskLinkRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i775.GetCurrentProjectQuery get getCurrentProjectQuery =>
      _i775.GetCurrentProjectQuery(_getIt<_i102.ProjectRepository>());

  @override
  _i676.GetAllProjectsQuery get getAllProjectsQuery =>
      _i676.GetAllProjectsQuery(_getIt<_i102.ProjectRepository>());

  @override
  _i74.TaskStartOperation get taskStartOperation => _i74.TaskStartOperation(
    _getIt<_i840.OperationPipeline>(),
    _getIt<_i159.TaskRepository>(),
    _getIt<_i512.DomainEventBus>(),
  );

  @override
  _i841.TaskDoneOperation get taskDoneOperation => _i841.TaskDoneOperation(
    _getIt<_i840.OperationPipeline>(),
    _getIt<_i159.TaskRepository>(),
    _getIt<_i512.DomainEventBus>(),
  );

  @override
  _i545.TaskFailOperation get taskFailOperation => _i545.TaskFailOperation(
    _getIt<_i840.OperationPipeline>(),
    _getIt<_i159.TaskRepository>(),
    _getIt<_i512.DomainEventBus>(),
  );

  @override
  _i781.TaskCancelOperation get taskCancelOperation =>
      _i781.TaskCancelOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i159.TaskRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i906.TaskHoldOperation get taskHoldOperation => _i906.TaskHoldOperation(
    _getIt<_i840.OperationPipeline>(),
    _getIt<_i159.TaskRepository>(),
    _getIt<_i512.DomainEventBus>(),
  );

  @override
  _i96.TaskDeleteOperation get taskDeleteOperation => _i96.TaskDeleteOperation(
    _getIt<_i840.OperationPipeline>(),
    _getIt<_i159.TaskRepository>(),
    _getIt<_i512.DomainEventBus>(),
  );

  @override
  _i406.ProjectUpdateOperation get projectUpdateOperation =>
      _i406.ProjectUpdateOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i480.ProjectRenameOperation>(),
        _getIt<_i789.ProjectChangeDescriptionOperation>(),
      );
}
