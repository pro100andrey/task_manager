import 'dart:async';

import 'package:args/command_runner.dart';

import '../../mcp/server.dart';

class StartCommand extends Command<int> {
  StartCommand();

  @override
  String get description => 'Start the task manager';

  @override
  String get name => 'start';

  @override
  FutureOr<int>? run() async {
    final server = TaskManagerMcpServer();
    await server.start(McpConfigHttp(3000));
    return 0;
  }
}
