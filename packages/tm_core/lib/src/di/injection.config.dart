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

import '../application/ports/domain_event_bus.dart' as _i512;
import '../application/ports/tracing_port.dart' as _i969;
import '../application/ports/transaction_port.dart' as _i1007;
import '../application/repositories/project_repository.dart' as _i649;
import '../domain/queries/project/get_all_projects_query.dart' as _i938;
import '../domain/queries/project/get_current_project_query.dart' as _i177;
import '../operations/project/project_create_operation.dart' as _i279;
import 'modules/application_module.dart' as _i705;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initTmCore(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final applicationModule = _$ApplicationModule(getIt);
  gh.lazySingleton<_i177.GetCurrentProjectQuery>(
    () => applicationModule.getCurrentProjectQuery,
  );
  gh.lazySingleton<_i938.GetAllProjectsQuery>(
    () => applicationModule.getAllProjectsQuery,
  );
  gh.lazySingleton<_i279.ProjectCreateOperation>(
    () => applicationModule.projectCreateOperation,
  );
  return getIt;
}

class _$ApplicationModule extends _i705.ApplicationModule {
  _$ApplicationModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i177.GetCurrentProjectQuery get getCurrentProjectQuery =>
      _i177.GetCurrentProjectQuery(_getIt<_i649.ProjectRepository>());

  @override
  _i938.GetAllProjectsQuery get getAllProjectsQuery =>
      _i938.GetAllProjectsQuery(_getIt<_i649.ProjectRepository>());

  @override
  _i279.ProjectCreateOperation get projectCreateOperation =>
      _i279.ProjectCreateOperation(
        _getIt<_i1007.TransactionPort>(),
        _getIt<_i649.ProjectRepository>(),
        _getIt<_i512.DomainEventBus>(),
        _getIt<_i969.TracingPort>(),
      );
}
