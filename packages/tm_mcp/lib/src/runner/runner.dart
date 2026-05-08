import 'dart:io';

import 'package:args/command_runner.dart';

import 'command/start_command.dart';

Future<int> run(List<String> args) async {
  final runner = CommandRunner<int>('tm_mcp', 'Task manager MCP')
    ..addCommand(StartCommand());
  try {
    final result = await runner.run(args);
    return result ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    // runner.printUsage();
    return 64; // EX_USAGE
  }
}
