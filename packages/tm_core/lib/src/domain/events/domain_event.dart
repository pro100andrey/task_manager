import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/project.dart';
import '../value_objects/project/project_id.dart';
import '../value_objects/task/task_id.dart';

part 'domain_event.freezed.dart';

@freezed
sealed class DomainEvent with _$DomainEvent {
  const DomainEvent._();

  const factory DomainEvent.projectCreated({
    required Project project,
  }) = ProjectCreatedEvent;

  const factory DomainEvent.projectRenamed({
    required Project project,
  }) = ProjectRenamedEvent;

  const factory DomainEvent.projectDescriptionChanged({
    required Project project,
  }) = ProjectDescriptionChangedEvent;

  const factory DomainEvent.projectDeleted({
    required ProjectId projectId,
  }) = ProjectDeletedEvent;

  const factory DomainEvent.projectSwitched({
    required Project currentProject,
    Project? previousProject,
  }) = ProjectSwitchedEvent;

  const factory DomainEvent.taskCreated({
    required TaskId taskId,
  }) = TaskCreatedEvent;

  const factory DomainEvent.taskCompleted({
    required TaskId taskId,
  }) = TaskCompletedEvent;

  const factory DomainEvent.taskReplanned({
    required TaskId taskId,
  }) = TaskReplannedEvent;
}
