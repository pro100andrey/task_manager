import 'package:get_it/get_it.dart';
import 'package:tm_core/src/application/operations/project/project_create_command.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/di/injection.dart';

final getIt = GetIt.instance;
Future<void> main() async {
  await configureTmCoreDependencies();

  final createOp = getIt<ProjectCreateOperation>();

  final _ = await createOp.execute(
    const ProjectCreateCommand(
      name: 'My first project',
      description: 'This is a sample project',
    ),
  );
}
