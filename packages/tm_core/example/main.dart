import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tm_core/tm_core.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  await configureTmCoreDependencies(
    loggingConfig: TracingLoggingConfig(
      rootLevel: Level.ALL,
      loggerName: 'tm_core',
      onRecord: (record) => stdout.writeln(
        '[${record.level.name}] ${record.loggerName}: ${record.message}',
      ),
    ),
  );

  final createOp = getIt<ProjectCreateOperation>();

  final project = await createOp.execute(
    const ProjectCreateCommand(
      name: 'My first project',
      description: 'This is a sample project',
    ),
  );

  if (project.isFailure) {
    stdout.writeln('Failed to create project: ${project.error}');
    exit(1);
  }

  final projectId = project.value!.id;

  final renameOp = getIt<ProjectRenameOperation>();
  final renameResult = await renameOp.execute(
    const ProjectRenameCommand(
      projectId: '019df825-cdfc-7988-a7ad-7cf3b5a74a51',
      newName: 'Renamed project',
    ),
  );

  if (renameResult.isFailure) {
    stdout.writeln('Project rename failed: ${renameResult.error}');
    exit(1);
  }
}
