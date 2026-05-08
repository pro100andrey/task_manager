import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

import 'project_tools.dart';

const _instructions =
    'You are a helpful assistant for managing projects in '
    'the Task Manager application. You have access to the following tools for'
    ' working with projects:\n'
    '- project-get-current: Get the current project\n'
    '- project-rename: Rename the current project\n'
    '- project-create: Create a new project\n'
    'When using the tools, make sure to provide all required input parameters. '
    'Always check the output of the tools for any error messages or important '
    'information.';

McpServer _buildServer() {
  final server =
      McpServer(
          const Implementation(name: 'task-manager-mcp', version: '1.0.0'),
          options: const McpServerOptions(
            instructions: _instructions,
            capabilities: ServerCapabilities(
              tools: ServerCapabilitiesTools(),
              resources: ServerCapabilitiesResources(),
              prompts: ServerCapabilitiesPrompts(),
            ),
          ),
        )
        ..registerProjectGetCurrent()
        ..registerProjectRename()
        ..registerProjectCreate();

  return server;
}

sealed class McpConfig {}

final class McpConfigStdio extends McpConfig {}

final class McpConfigHttp extends McpConfig {
  McpConfigHttp(this.port);
  final int port;
}

class TaskManagerMcpServer {
  Future<void> start(McpConfig config) async {
    setMcpLogHandler((loggerName, level, message) {
      stdout.writeln('[${level.name.toUpperCase()}] [$loggerName] $message');
    });

    switch (config) {
      case McpConfigStdio():
        final transport = StdioServerTransport();
        final server = _buildServer();
        await server.connect(transport);
      case McpConfigHttp(:final port):
        final transport = StreamableHTTPServerTransport(
          options: StreamableHTTPServerTransportOptions(
            sessionIdGenerator: () => null,
            eventStore: InMemoryEventStore(),
            allowedHosts: {'localhost'},
            allowedOrigins: {'http://localhost:$port'},
          ),
        );

        final server = _buildServer();
        await server.connect(transport);

        final httpServer = await HttpServer.bind('localhost', port);

        stdout.writeln('Server listening on http://localhost:$port');

        await for (final request in httpServer) {
          if (request.uri.path != '/mcp') {
            request.response
              ..statusCode = HttpStatus.notFound
              ..write('Not Found');
            await request.response.close();
            continue;
          }

          await transport.handleRequest(request);
        }
    }
  }
}
