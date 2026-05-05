import '../../command.dart';

class TaskRenameAliasCommand extends Command {
  const TaskRenameAliasCommand({required this.taskId, this.alias});

  final String taskId;

  /// null = clear the alias.
  final String? alias;
}
