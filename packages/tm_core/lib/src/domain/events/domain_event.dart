import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/project.dart';
import '../value_objects/project/project_id.dart';
import '../value_objects/task/task_alias.dart';
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

  const factory DomainEvent.taskStarted({
    required TaskId taskId,
  }) = TaskStartedEvent;

  const factory DomainEvent.taskCompleted({
    required TaskId taskId,
  }) = TaskCompletedEvent;

  const factory DomainEvent.taskFailed({
    required TaskId taskId,
    String? reason,
  }) = TaskFailedEvent;

  const factory DomainEvent.taskCancelled({
    required TaskId taskId,
    String? reason,
  }) = TaskCancelledEvent;

  const factory DomainEvent.taskPutOnHold({
    required TaskId taskId,
    String? reason,
  }) = TaskPutOnHoldEvent;

  const factory DomainEvent.taskDeleted({
    required TaskId taskId,
  }) = TaskDeletedEvent;

  const factory DomainEvent.taskReplanned({
    required TaskId taskId,
  }) = TaskReplannedEvent;

  const factory DomainEvent.taskUpdated({
    required TaskId taskId,
  }) = TaskUpdatedEvent;

  const factory DomainEvent.taskContextChanged({
    required TaskId taskId,
    required String contextState,
  }) = TaskContextChangedEvent;

  const factory DomainEvent.taskMoved({
    required TaskId taskId,
    TaskId? newParentId,
  }) = TaskMovedEvent;

  const factory DomainEvent.taskAliasRenamed({
    required TaskId taskId,
    TaskAlias? newAlias,
  }) = TaskAliasRenamedEvent;

  const factory DomainEvent.taskLinkAdded({
    required TaskId fromTaskId,
    required TaskId toTaskId,
    required String linkType,
  }) = TaskLinkAddedEvent;

  const factory DomainEvent.taskLinkRemoved({
    required TaskId fromTaskId,
    required TaskId toTaskId,
    required String linkType,
  }) = TaskLinkRemovedEvent;
}
