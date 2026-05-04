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
import '../adapters/tracing/logging_tracing_port_impl.dart' as _i629;
import '../adapters/transaction/no_op_transaction_port_impl.dart' as _i1016;
import '../application/operations/operation_pipeline.dart' as _i840;
import '../application/operations/project/project_change_description_operation.dart'
    as _i789;
import '../application/operations/project/project_create_operation.dart'
    as _i797;
import '../application/operations/project/project_rename_operation.dart'
    as _i480;
import '../application/operations/project/project_update_operation.dart'
    as _i406;
import '../application/ports/domain_event_bus.dart' as _i512;
import '../application/ports/project_repository.dart' as _i102;
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
  final coreModule = _$CoreModule();
  final applicationModule = _$ApplicationModule(getIt);
  gh.lazySingleton<_i1007.TransactionPort>(
    () => coreModule.noOpTransactionPort,
  );
  gh.lazySingleton<_i102.ProjectRepository>(
    () => coreModule.projectsRepository,
  );
  gh.lazySingleton<_i512.DomainEventBus>(() => coreModule.domainEventBus);
  gh.lazySingleton<_i969.TracingPort>(() => coreModule.tracingPort);
  gh.lazySingleton<_i840.OperationPipeline>(
    () => coreModule.operationPipeline(
      gh<_i969.TracingPort>(),
      gh<_i1007.TransactionPort>(),
    ),
  );
  gh.lazySingleton<_i797.ProjectCreateOperation>(
    () => applicationModule.projectCreateOperation,
  );
  gh.lazySingleton<_i775.GetCurrentProjectQuery>(
    () => applicationModule.getCurrentProjectQuery,
  );
  gh.lazySingleton<_i676.GetAllProjectsQuery>(
    () => applicationModule.getAllProjectsQuery,
  );
  gh.lazySingleton<_i480.ProjectRenameOperation>(
    () => applicationModule.projectRenameOperation,
  );
  gh.lazySingleton<_i789.ProjectChangeDescriptionOperation>(
    () => applicationModule.projectChangeDescriptionOperation,
  );
  gh.lazySingleton<_i406.ProjectUpdateOperation>(
    () => applicationModule.projectUpdateOperation,
  );
  return getIt;
}

class _$CoreModule extends _i154.CoreModule {
  @override
  _i1016.NoOpTransactionPortImpl get noOpTransactionPort =>
      _i1016.NoOpTransactionPortImpl();

  @override
  _i949.MemProjectsRepositoryImpl get projectsRepository =>
      _i949.MemProjectsRepositoryImpl();

  @override
  _i1027.OrderedDomainEventBusImpl get domainEventBus =>
      _i1027.OrderedDomainEventBusImpl();

  @override
  _i629.LoggingTracingPortImpl get tracingPort =>
      _i629.LoggingTracingPortImpl();
}

class _$ApplicationModule extends _i705.ApplicationModule {
  _$ApplicationModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i797.ProjectCreateOperation get projectCreateOperation =>
      _i797.ProjectCreateOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
      );

  @override
  _i775.GetCurrentProjectQuery get getCurrentProjectQuery =>
      _i775.GetCurrentProjectQuery(_getIt<_i102.ProjectRepository>());

  @override
  _i676.GetAllProjectsQuery get getAllProjectsQuery =>
      _i676.GetAllProjectsQuery(_getIt<_i102.ProjectRepository>());

  @override
  _i480.ProjectRenameOperation get projectRenameOperation =>
      _i480.ProjectRenameOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
      );

  @override
  _i789.ProjectChangeDescriptionOperation
  get projectChangeDescriptionOperation =>
      _i789.ProjectChangeDescriptionOperation(
        _getIt<_i840.OperationPipeline>(),
        _getIt<_i102.ProjectRepository>(),
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
