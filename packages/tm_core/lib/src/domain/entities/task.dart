import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/task_id.dart';
import '../value_objects/task_title.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required TaskId id,
    required TaskTitle title,
    TaskId? parentId,
  }) = _Task;
}
