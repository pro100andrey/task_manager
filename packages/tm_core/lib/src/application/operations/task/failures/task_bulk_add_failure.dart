import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_bulk_add_failure.freezed.dart';

@freezed
class TaskBulkAddFailure with _$TaskBulkAddFailure {
  const factory TaskBulkAddFailure.validationError(String message) =
      TaskBulkAddValidationError;

  const factory TaskBulkAddFailure.projectNotFound(String projectId) =
      TaskBulkAddProjectNotFound;

  const factory TaskBulkAddFailure.parentNotFound(String parentId) =
      TaskBulkAddParentNotFound;

  const factory TaskBulkAddFailure.taskCreationFailed(
    int taskIndex,
    String message,
  ) = TaskBulkAddTaskCreationFailed;

  const factory TaskBulkAddFailure.tooManyTasks(int count, int maxCount) =
      TaskBulkAddTooManyTasks;
}
