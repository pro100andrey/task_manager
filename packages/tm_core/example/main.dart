import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:tm_core/tm_core.dart';

Future<void> main() async {
  await configureTmCoreDependencies();

  final createOp = GetIt.I<ProjectCreateOperation>();

  final project = await createOp.execute(
    const ProjectCreateCommand(
      name: .new('My first project'),
      description: .new('This is a sample project'),
    ),
  );

  if (project.isFailure) {
    exit(1);
  }

  final projectId = project.value!.id;

  final renameOp = GetIt.I<ProjectRenameOperation>();
  final renameResult = await renameOp.execute(
    ProjectRenameCommand(
      projectId: projectId,
      newName: const .new('Renamed project'),
    ),
  );

  if (renameResult.isFailure) {
    exit(1);
  }
}
