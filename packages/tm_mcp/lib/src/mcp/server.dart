import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

McpServer _buildServer() {
  final server =
      McpServer(
        const Implementation(name: 'task-manager-mcp', version: '1.0.0'),
        options: const McpServerOptions(
          capabilities: ServerCapabilities(
            tools: ServerCapabilitiesTools(),
            resources: ServerCapabilitiesResources(),
            prompts: ServerCapabilitiesPrompts(),
          ),
        ),
      )..registerResource(
        'Server Info',
        'info://server',
        null,
        (uri, extra) => ReadResourceResult(
          contents: [
            TextResourceContents(
              uri: uri.toString(),
              text: 'Task Manager MCP Server\nVersion: 1.0.0',
              mimeType: 'text/plain',
            ),
          ],
        ),
      );

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
            sessionIdGenerator: () =>
                'session-${DateTime.now().millisecondsSinceEpoch}',
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
