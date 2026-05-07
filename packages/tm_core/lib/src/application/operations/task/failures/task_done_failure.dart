import '../../../../domain/value_objects/task/task_id.dart';

sealed class TaskDoneFailure {
  const TaskDoneFailure();
}

final class TaskDoneNotFound extends TaskDoneFailure {
  const TaskDoneNotFound(this.taskId);
  final TaskId taskId;
}

final class TaskDoneInvalidTransition extends TaskDoneFailure {
  const TaskDoneInvalidTransition({required this.from, required this.to});
  final String from;
  final String to;
}

final class TaskDoneNotCompletable extends TaskDoneFailure {
  const TaskDoneNotCompletable(this.taskId);
  final TaskId taskId;
}
