import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/link_type.dart';
import '../value_objects/task/task_id.dart';

part 'task_link.freezed.dart';

@freezed
abstract class TaskLink with _$TaskLink {
  const factory TaskLink({
    required String id,
    required TaskId fromTaskId,
    required TaskId toTaskId,
    required LinkType linkType,
    required DateTime createdAt,
    String? label,
  }) = _TaskLink;
}
