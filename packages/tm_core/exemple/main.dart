import 'dart:io';

import 'package:tm_core/src/domain/value_objects/value_objects.dart';

Future<void> main() async {
  stdout.writeln('Hello world!');

  final projectId = ProjectId.generate();
  final ref1 = ProjectRef.id(projectId);
  final projectName = ProjectName('My Project');
  final ref2 = ProjectRef.name(projectName);

  stdout
    ..writeln('Project ID: $projectId')
    ..writeln(
      'Project Ref 1: $ref1 (isId: ${ref1.isId}, isName: ${ref1.isName})',
    )
    ..writeln(
      'Project Ref 2: $ref2 (isId: ${ref2.isId}, isName: ${ref2.isName})',
    );
}
