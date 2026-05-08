import 'package:get_it/get_it.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:tm_core/tm_core.dart';

extension McpServerProjectTools on McpServer {
  void registerProjectGetCurrent() => registerTool(
    'project-get-current',
    title: 'Current Project',
    description: 'Get the current project',
    outputSchema: ToolOutputSchema(
      properties: {
        'projectId': .oneOf([
          .string(description: 'The ID of the current project'),
          .nullValue(),
        ]),
      },
    ),
    callback: (args, extra) async {
      final getCurrentOp = GetIt.I<GetCurrentProjectQuery>();
      final proj = await getCurrentOp.execute();

      if (proj == null) {
        return const CallToolResult(
          content: [TextContent(text: 'No current project')],
          structuredContent: {'projectId': null},
        );
      }

      return CallToolResult(
        content: [TextContent(text: 'Current project ID: ${proj.id}')],
        structuredContent: {'projectId': proj.id},
      );
    },
  );

  void registerProjectRename() => registerTool(
    'project-rename',
    title: 'Rename Project',
    description: 'Rename the current project',
    inputSchema: ToolInputSchema(
      properties: {
        'projectId': .string(description: 'The ID of the project to rename'),
        'newName': JsonSchema.string(),
      },
    ),
    callback: (args, extra) async {
      final renameOp = GetIt.I<ProjectRenameOperation>();
      final newName = args['newName'] as String;
      final projectId = args['projectId'] as String?;

      if (projectId == null) {
        return const CallToolResult(
          content: [TextContent(text: 'No project ID provided')],
        );
      }
      final renameResult = await renameOp.execute(
        ProjectRenameCommand(
          projectId: .new(projectId),
          newName: .new(newName),
        ),
      );

      if (renameResult.isFailure) {
        return CallToolResult(
          content: [
            TextContent(
              text: 'Failed to rename project: ${renameResult.value}',
            ),
          ],
        );
      }

      return const CallToolResult(
        content: [TextContent(text: 'Project renamed successfully')],
      );
    },
  );

  void registerProjectCreate() => registerTool(
    'project-create',
    title: 'Create Project',
    description: 'Create a new project with a name and description',
    outputSchema: ToolOutputSchema(
      title: 'Created Project ID',
      description: 'The result contains the ID of the created project',
      properties: {
        'projectId': .string(description: 'The ID of the created project'),
      },
      required: ['projectId'],
    ),
    inputSchema: ToolInputSchema(
      properties: {
        'name': JsonSchema.string(
          minLength: 10,
          maxLength: 56,
          title: 'Project Name',
          description: 'The name of the project (max 56 characters)',
          pattern: r'^[a-zA-Z0-9 _-]+$',
        ),
        'description': JsonSchema.string(
          minLength: 50,
          maxLength: 1024,
          title: 'Project Description',
          description: 'The description of the project (max 1024 characters)',
        ),
      },
      required: ['name', 'description'],
    ),
    callback: (args, extra) async {
      final createOp = GetIt.I<ProjectCreateOperation>();
      final name = args['name'] as String;
      final description = args['description'] as String;
      final project = await createOp.execute(
        ProjectCreateCommand(
          name: .new(name),
          description: .new(description),
        ),
      );

      if (project.isFailure) {
        return CallToolResult.fromStructuredContent({
          'projectId': null,
          'error': 'Failed to create project: ${project.error!}',
        });
      }

      final created = project.value!;

      return CallToolResult.fromStructuredContent({
        'projectId': created.id.value,
      });
    },
  );
}
