import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:tm_core/src/di/injection.dart';
import 'package:tm_core/src/operations/project/project_create_operation.dart';

final getIt = GetIt.instance;
Future<void> main() async {
  await setupDependencies();

  final createOp = getIt<ProjectCreateOperation>();
  final result = await createOp.execute(
    'My first project',
    description: 'This is a sample project',
  );

  if (result is Exception) {
    stdout.writeln('Failed to create project: $result');
  } else {
    stdout.writeln('Project created successfully: $result');
  }
}

Future<void> setupDependencies() async {
  // environment: 'dev' | 'prod' | 'test'
  await configureTmCoreDependencies();
}
