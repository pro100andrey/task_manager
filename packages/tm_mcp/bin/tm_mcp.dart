import 'dart:io';

import 'package:tm_mcp/src/runner/runner.dart';

Future<void> main(List<String> args) async {
  final result = await run(args);

  exit(result);
}
