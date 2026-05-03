import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/task_id.dart';

part 'domain_event.freezed.dart';

@freezed
abstract class DomainEvent with _$DomainEvent {
  const factory DomainEvent.taskCreated({
    required TaskId taskId,
  }) = TaskCreated;

  const factory DomainEvent.taskCompleted({
    required String taskId,
  }) = TaskCompleted;

  const factory DomainEvent.taskReplanned({
    required String taskId,
  }) = TaskReplanned;
}
