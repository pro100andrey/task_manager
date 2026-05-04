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

import '../application/operations/project/project_create_operation.dart'
    as _i797;
import '../application/ports/domain_event_bus.dart' as _i512;
import '../application/ports/tracing_port.dart' as _i969;
import '../application/ports/transaction_port.dart' as _i1007;
import '../application/queries/project/get_all_projects_query.dart' as _i676;
import '../application/queries/project/get_current_project_query.dart' as _i775;
import '../application/repositories/project_repository.dart' as _i649;
import '../infra/events/ordered_domain_bus_impl.dart' as _i978;
import '../infra/no_op_transaction_port_impl.dart' as _i1059;
import '../infra/repositories/mem_projects_repository_impl.dart' as _i592;
import '../infra/tracing/logging_tracing_port.dart' as _i381;
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
  gh.lazySingleton<_i512.DomainEventBus>(() => coreModule.domainEventBus);
  gh.lazySingleton<_i1007.TransactionPort>(
    () => coreModule.noOpTransactionPort,
  );
  gh.lazySingleton<_i969.TracingPort>(() => coreModule.tracingPort);
  gh.lazySingleton<_i649.ProjectRepository>(
    () => coreModule.projectsRepository,
  );
  gh.lazySingleton<_i775.GetCurrentProjectQuery>(
    () => applicationModule.getCurrentProjectQuery,
  );
  gh.lazySingleton<_i676.GetAllProjectsQuery>(
    () => applicationModule.getAllProjectsQuery,
  );
  gh.lazySingleton<_i797.ProjectCreateOperation>(
    () => applicationModule.projectCreateOperation,
  );
  return getIt;
}

class _$CoreModule extends _i154.CoreModule {
  @override
  _i978.OrderedDomainEventBusImpl get domainEventBus =>
      _i978.OrderedDomainEventBusImpl();

  @override
  _i1059.NoOpTransactionPortImpl get noOpTransactionPort =>
      _i1059.NoOpTransactionPortImpl();

  @override
  _i381.LoggingTracingPortImpl get tracingPort =>
      _i381.LoggingTracingPortImpl();

  @override
  _i592.MemProjectsRepositoryImpl get projectsRepository =>
      _i592.MemProjectsRepositoryImpl();
}

class _$ApplicationModule extends _i705.ApplicationModule {
  _$ApplicationModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i775.GetCurrentProjectQuery get getCurrentProjectQuery =>
      _i775.GetCurrentProjectQuery(_getIt<_i649.ProjectRepository>());

  @override
  _i676.GetAllProjectsQuery get getAllProjectsQuery =>
      _i676.GetAllProjectsQuery(_getIt<_i649.ProjectRepository>());

  @override
  _i797.ProjectCreateOperation get projectCreateOperation =>
      _i797.ProjectCreateOperation(
        _getIt<_i1007.TransactionPort>(),
        _getIt<_i649.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
        _getIt<_i969.TracingPort>(),
      );
}
