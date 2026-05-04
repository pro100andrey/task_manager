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
import '../application/ports/transaction_port.dart' as _i1007;
import '../application/repositories/project_repository.dart' as _i649;
import '../infra/events/domain_event_bus_impl.dart' as _i264;
import 'core_module.dart' as _i154;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initTmCore(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final coreModule = _$CoreModule();
  gh.lazySingleton<_i512.DomainEventBus>(() => _i264.DomainEventBusImpl());
  gh.lazySingleton<_i1007.TransactionPort>(
    () => coreModule.noOpTransactionPort,
  );
  gh.lazySingleton<_i649.ProjectRepository>(
    () => coreModule.projectsRepository,
  );
  return getIt;
}

class _$CoreModule extends _i154.CoreModule {}
