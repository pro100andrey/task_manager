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

  switch (project) {
    case Success(:final value):
      stdout.writeln(
        'Project created: ${value.name.value} (id: ${value.id.value})',
      );
    case Failure(:final error):
      switch (error) {
        case ProjectCreateNameAlreadyExists(:final name):
          stdout.writeln(
            'Failed to create project: name already exists ($name)',
          );
        case ProjectCreateInvalidName(:final reason):
          stdout.writeln('Failed to create project: invalid name ($reason)');
        case ProjectCreateInvalidDescription(:final reason):
          stdout.writeln(
            'Failed to create project: invalid description ($reason)',
          );
      }
  }

  final project2 = await createOp.execute(
    const ProjectCreateCommand(
      name: 'My first project',
      description: 'This is a sample project',
    ),
  );

  switch (project2) {
    case Success(:final value):
      stdout.writeln(
        'Project created: ${value.name.value} (id: ${value.id.value})',
      );
    case Failure(:final error):
      switch (error) {
        case ProjectCreateNameAlreadyExists(:final name):
          stdout.writeln(
            'Failed to create project: name already exists ($name)',
          );
        case ProjectCreateInvalidName(:final reason):
          stdout.writeln('Failed to create project: invalid name ($reason)');
        case ProjectCreateInvalidDescription(:final reason):
          stdout.writeln(
            'Failed to create project: invalid description ($reason)',
          );
      }
  }
}
