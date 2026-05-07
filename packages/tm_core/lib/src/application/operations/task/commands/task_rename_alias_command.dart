import '../../../../domain/value_objects/task/task_alias.dart';
import '../../../../domain/value_objects/value_objects.dart';
import '../../command.dart';

class TaskRenameAliasCommand extends Command {
  const TaskRenameAliasCommand({required this.taskId, this.alias});

  final TaskId taskId;

  final TaskAlias? alias;
}
