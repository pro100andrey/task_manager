import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/task_id.dart';

part 'domain_event.freezed.dart';

@freezed
sealed class DomainEvent with _$DomainEvent {
  const DomainEvent._();

  const factory DomainEvent.taskCreated({
    required TaskId taskId,
  }) = TaskCreated;

  const factory DomainEvent.taskCompleted({
    required TaskId taskId,
  }) = TaskCompleted;

  const factory DomainEvent.taskReplanned({
    required TaskId taskId,
  }) = TaskReplanned;

  String get entityKey => taskId.value;
}
