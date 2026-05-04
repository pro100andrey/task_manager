import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:tm_core/src/application/operations/project/project_create_operation.dart';
import 'package:tm_core/src/di/injection.dart';
import 'package:tm_core/src/domain/results/result.dart';

final getIt = GetIt.instance;
Future<void> main() async {
  await setupDependencies();

  final createOp = getIt<ProjectCreateOperation>();
  final result = await createOp.execute(
    'My first project',
    description: 'This is a sample project',
  );

  switch (result) {
    case Success(:final value):
      stdout.writeln('Project created successfully: $value');
    case Failure(:final error):
      stdout.writeln('Failed to create project: $error');
  }
}

Future<void> setupDependencies() async {
  // environment: 'dev' | 'prod' | 'test'
  await configureTmCoreDependencies();
}
