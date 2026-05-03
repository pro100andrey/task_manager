import 'operation.dart';

final class TaskDoneOperation extends Operation {
  TaskDoneOperation(this.taskId);

  final String taskId;
}
