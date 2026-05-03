import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/task_status.dart';
import '../value_objects/task_description.dart';
import '../value_objects/task_id.dart';
import '../value_objects/task_title.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required TaskId id,
    required TaskTitle title,
    required TaskStatus status,
    TaskId? parentId,
    TaskDescription? description,
  }) = _Task;
}
