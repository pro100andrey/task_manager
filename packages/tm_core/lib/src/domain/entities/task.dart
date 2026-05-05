import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/task_completion_policy.dart';
import '../enums/task_context_state.dart';
import '../enums/task_last_action_type.dart';
import '../enums/task_status.dart';
import '../value_objects/project/project_id.dart';
import '../value_objects/task/task_alias.dart';
import '../value_objects/task/task_description.dart';
import '../value_objects/task/task_id.dart';
import '../value_objects/task/task_title.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required TaskId id,
    required ProjectId projectId,
    required TaskTitle title,
    required TaskStatus status,
    required TaskContextState contextState,
    required TaskCompletionPolicy completionPolicy,
    required int businessValue,
    required int urgencyScore,
    required TaskLastActionType lastActionType,
    required DateTime lastProgressAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<String> tags,
    required Map<String, dynamic> metadata,
    required int planVersion,
    TaskId? parentId,
    TaskAlias? alias,
    String? normalizedAlias,
    TaskDescription? description,
    String? statusReason,
    double? estimatedEffort,
    DateTime? dueDate,
    String? assignedTo,
    DateTime? completedAt,
  }) = _Task;
}
