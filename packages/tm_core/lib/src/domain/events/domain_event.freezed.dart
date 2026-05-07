// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DomainEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DomainEvent()';
}


}

/// @nodoc
class $DomainEventCopyWith<$Res>  {
$DomainEventCopyWith(DomainEvent _, $Res Function(DomainEvent) __);
}



/// @nodoc


class ProjectCreatedEvent extends DomainEvent {
  const ProjectCreatedEvent({required this.project}): super._();
  

 final  Project project;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCreatedEventCopyWith<ProjectCreatedEvent> get copyWith => _$ProjectCreatedEventCopyWithImpl<ProjectCreatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectCreatedEvent&&(identical(other.project, project) || other.project == project));
}


@override
int get hashCode => Object.hash(runtimeType,project);

@override
String toString() {
  return 'DomainEvent.projectCreated(project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectCreatedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $ProjectCreatedEventCopyWith(ProjectCreatedEvent value, $Res Function(ProjectCreatedEvent) _then) = _$ProjectCreatedEventCopyWithImpl;
@useResult
$Res call({
 Project project
});


$ProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$ProjectCreatedEventCopyWithImpl<$Res>
    implements $ProjectCreatedEventCopyWith<$Res> {
  _$ProjectCreatedEventCopyWithImpl(this._self, this._then);

  final ProjectCreatedEvent _self;
  final $Res Function(ProjectCreatedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? project = null,}) {
  return _then(ProjectCreatedEvent(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,
  ));
}

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class ProjectRenamedEvent extends DomainEvent {
  const ProjectRenamedEvent({required this.project}): super._();
  

 final  Project project;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectRenamedEventCopyWith<ProjectRenamedEvent> get copyWith => _$ProjectRenamedEventCopyWithImpl<ProjectRenamedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectRenamedEvent&&(identical(other.project, project) || other.project == project));
}


@override
int get hashCode => Object.hash(runtimeType,project);

@override
String toString() {
  return 'DomainEvent.projectRenamed(project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectRenamedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $ProjectRenamedEventCopyWith(ProjectRenamedEvent value, $Res Function(ProjectRenamedEvent) _then) = _$ProjectRenamedEventCopyWithImpl;
@useResult
$Res call({
 Project project
});


$ProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$ProjectRenamedEventCopyWithImpl<$Res>
    implements $ProjectRenamedEventCopyWith<$Res> {
  _$ProjectRenamedEventCopyWithImpl(this._self, this._then);

  final ProjectRenamedEvent _self;
  final $Res Function(ProjectRenamedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? project = null,}) {
  return _then(ProjectRenamedEvent(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,
  ));
}

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class ProjectDescriptionChangedEvent extends DomainEvent {
  const ProjectDescriptionChangedEvent({required this.project}): super._();
  

 final  Project project;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDescriptionChangedEventCopyWith<ProjectDescriptionChangedEvent> get copyWith => _$ProjectDescriptionChangedEventCopyWithImpl<ProjectDescriptionChangedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDescriptionChangedEvent&&(identical(other.project, project) || other.project == project));
}


@override
int get hashCode => Object.hash(runtimeType,project);

@override
String toString() {
  return 'DomainEvent.projectDescriptionChanged(project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectDescriptionChangedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $ProjectDescriptionChangedEventCopyWith(ProjectDescriptionChangedEvent value, $Res Function(ProjectDescriptionChangedEvent) _then) = _$ProjectDescriptionChangedEventCopyWithImpl;
@useResult
$Res call({
 Project project
});


$ProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$ProjectDescriptionChangedEventCopyWithImpl<$Res>
    implements $ProjectDescriptionChangedEventCopyWith<$Res> {
  _$ProjectDescriptionChangedEventCopyWithImpl(this._self, this._then);

  final ProjectDescriptionChangedEvent _self;
  final $Res Function(ProjectDescriptionChangedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? project = null,}) {
  return _then(ProjectDescriptionChangedEvent(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,
  ));
}

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class ProjectDeletedEvent extends DomainEvent {
  const ProjectDeletedEvent({required this.projectId}): super._();
  

 final  ProjectId projectId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDeletedEventCopyWith<ProjectDeletedEvent> get copyWith => _$ProjectDeletedEventCopyWithImpl<ProjectDeletedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDeletedEvent&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,projectId);

@override
String toString() {
  return 'DomainEvent.projectDeleted(projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $ProjectDeletedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $ProjectDeletedEventCopyWith(ProjectDeletedEvent value, $Res Function(ProjectDeletedEvent) _then) = _$ProjectDeletedEventCopyWithImpl;
@useResult
$Res call({
 ProjectId projectId
});




}
/// @nodoc
class _$ProjectDeletedEventCopyWithImpl<$Res>
    implements $ProjectDeletedEventCopyWith<$Res> {
  _$ProjectDeletedEventCopyWithImpl(this._self, this._then);

  final ProjectDeletedEvent _self;
  final $Res Function(ProjectDeletedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,}) {
  return _then(ProjectDeletedEvent(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as ProjectId,
  ));
}


}

/// @nodoc


class ProjectSwitchedEvent extends DomainEvent {
  const ProjectSwitchedEvent({required this.currentProject, this.previousProject}): super._();
  

 final  Project currentProject;
 final  Project? previousProject;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectSwitchedEventCopyWith<ProjectSwitchedEvent> get copyWith => _$ProjectSwitchedEventCopyWithImpl<ProjectSwitchedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectSwitchedEvent&&(identical(other.currentProject, currentProject) || other.currentProject == currentProject)&&(identical(other.previousProject, previousProject) || other.previousProject == previousProject));
}


@override
int get hashCode => Object.hash(runtimeType,currentProject,previousProject);

@override
String toString() {
  return 'DomainEvent.projectSwitched(currentProject: $currentProject, previousProject: $previousProject)';
}


}

/// @nodoc
abstract mixin class $ProjectSwitchedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $ProjectSwitchedEventCopyWith(ProjectSwitchedEvent value, $Res Function(ProjectSwitchedEvent) _then) = _$ProjectSwitchedEventCopyWithImpl;
@useResult
$Res call({
 Project currentProject, Project? previousProject
});


$ProjectCopyWith<$Res> get currentProject;$ProjectCopyWith<$Res>? get previousProject;

}
/// @nodoc
class _$ProjectSwitchedEventCopyWithImpl<$Res>
    implements $ProjectSwitchedEventCopyWith<$Res> {
  _$ProjectSwitchedEventCopyWithImpl(this._self, this._then);

  final ProjectSwitchedEvent _self;
  final $Res Function(ProjectSwitchedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentProject = null,Object? previousProject = freezed,}) {
  return _then(ProjectSwitchedEvent(
currentProject: null == currentProject ? _self.currentProject : currentProject // ignore: cast_nullable_to_non_nullable
as Project,previousProject: freezed == previousProject ? _self.previousProject : previousProject // ignore: cast_nullable_to_non_nullable
as Project?,
  ));
}

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get currentProject {
  
  return $ProjectCopyWith<$Res>(_self.currentProject, (value) {
    return _then(_self.copyWith(currentProject: value));
  });
}/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res>? get previousProject {
    if (_self.previousProject == null) {
    return null;
  }

  return $ProjectCopyWith<$Res>(_self.previousProject!, (value) {
    return _then(_self.copyWith(previousProject: value));
  });
}
}

/// @nodoc


class TaskCreatedEvent extends DomainEvent {
  const TaskCreatedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCreatedEventCopyWith<TaskCreatedEvent> get copyWith => _$TaskCreatedEventCopyWithImpl<TaskCreatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCreatedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskCreated(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskCreatedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskCreatedEventCopyWith(TaskCreatedEvent value, $Res Function(TaskCreatedEvent) _then) = _$TaskCreatedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskCreatedEventCopyWithImpl<$Res>
    implements $TaskCreatedEventCopyWith<$Res> {
  _$TaskCreatedEventCopyWithImpl(this._self, this._then);

  final TaskCreatedEvent _self;
  final $Res Function(TaskCreatedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskCreatedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskStartedEvent extends DomainEvent {
  const TaskStartedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskStartedEventCopyWith<TaskStartedEvent> get copyWith => _$TaskStartedEventCopyWithImpl<TaskStartedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskStartedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskStarted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskStartedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskStartedEventCopyWith(TaskStartedEvent value, $Res Function(TaskStartedEvent) _then) = _$TaskStartedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskStartedEventCopyWithImpl<$Res>
    implements $TaskStartedEventCopyWith<$Res> {
  _$TaskStartedEventCopyWithImpl(this._self, this._then);

  final TaskStartedEvent _self;
  final $Res Function(TaskStartedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskStartedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskCompletedEvent extends DomainEvent {
  const TaskCompletedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCompletedEventCopyWith<TaskCompletedEvent> get copyWith => _$TaskCompletedEventCopyWithImpl<TaskCompletedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCompletedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskCompleted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskCompletedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskCompletedEventCopyWith(TaskCompletedEvent value, $Res Function(TaskCompletedEvent) _then) = _$TaskCompletedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskCompletedEventCopyWithImpl<$Res>
    implements $TaskCompletedEventCopyWith<$Res> {
  _$TaskCompletedEventCopyWithImpl(this._self, this._then);

  final TaskCompletedEvent _self;
  final $Res Function(TaskCompletedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskCompletedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskFailedEvent extends DomainEvent {
  const TaskFailedEvent({required this.taskId, this.reason}): super._();
  

 final  TaskId taskId;
 final  String? reason;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskFailedEventCopyWith<TaskFailedEvent> get copyWith => _$TaskFailedEventCopyWithImpl<TaskFailedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskFailedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,reason);

@override
String toString() {
  return 'DomainEvent.taskFailed(taskId: $taskId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TaskFailedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskFailedEventCopyWith(TaskFailedEvent value, $Res Function(TaskFailedEvent) _then) = _$TaskFailedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, String? reason
});




}
/// @nodoc
class _$TaskFailedEventCopyWithImpl<$Res>
    implements $TaskFailedEventCopyWith<$Res> {
  _$TaskFailedEventCopyWithImpl(this._self, this._then);

  final TaskFailedEvent _self;
  final $Res Function(TaskFailedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? reason = freezed,}) {
  return _then(TaskFailedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TaskCancelledEvent extends DomainEvent {
  const TaskCancelledEvent({required this.taskId, this.reason}): super._();
  

 final  TaskId taskId;
 final  String? reason;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCancelledEventCopyWith<TaskCancelledEvent> get copyWith => _$TaskCancelledEventCopyWithImpl<TaskCancelledEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCancelledEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,reason);

@override
String toString() {
  return 'DomainEvent.taskCancelled(taskId: $taskId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TaskCancelledEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskCancelledEventCopyWith(TaskCancelledEvent value, $Res Function(TaskCancelledEvent) _then) = _$TaskCancelledEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, String? reason
});




}
/// @nodoc
class _$TaskCancelledEventCopyWithImpl<$Res>
    implements $TaskCancelledEventCopyWith<$Res> {
  _$TaskCancelledEventCopyWithImpl(this._self, this._then);

  final TaskCancelledEvent _self;
  final $Res Function(TaskCancelledEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? reason = freezed,}) {
  return _then(TaskCancelledEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TaskPutOnHoldEvent extends DomainEvent {
  const TaskPutOnHoldEvent({required this.taskId, this.reason}): super._();
  

 final  TaskId taskId;
 final  String? reason;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskPutOnHoldEventCopyWith<TaskPutOnHoldEvent> get copyWith => _$TaskPutOnHoldEventCopyWithImpl<TaskPutOnHoldEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskPutOnHoldEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,reason);

@override
String toString() {
  return 'DomainEvent.taskPutOnHold(taskId: $taskId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TaskPutOnHoldEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskPutOnHoldEventCopyWith(TaskPutOnHoldEvent value, $Res Function(TaskPutOnHoldEvent) _then) = _$TaskPutOnHoldEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, String? reason
});




}
/// @nodoc
class _$TaskPutOnHoldEventCopyWithImpl<$Res>
    implements $TaskPutOnHoldEventCopyWith<$Res> {
  _$TaskPutOnHoldEventCopyWithImpl(this._self, this._then);

  final TaskPutOnHoldEvent _self;
  final $Res Function(TaskPutOnHoldEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? reason = freezed,}) {
  return _then(TaskPutOnHoldEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TaskDeletedEvent extends DomainEvent {
  const TaskDeletedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDeletedEventCopyWith<TaskDeletedEvent> get copyWith => _$TaskDeletedEventCopyWithImpl<TaskDeletedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDeletedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskDeleted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskDeletedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskDeletedEventCopyWith(TaskDeletedEvent value, $Res Function(TaskDeletedEvent) _then) = _$TaskDeletedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskDeletedEventCopyWithImpl<$Res>
    implements $TaskDeletedEventCopyWith<$Res> {
  _$TaskDeletedEventCopyWithImpl(this._self, this._then);

  final TaskDeletedEvent _self;
  final $Res Function(TaskDeletedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskDeletedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskReplannedEvent extends DomainEvent {
  const TaskReplannedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskReplannedEventCopyWith<TaskReplannedEvent> get copyWith => _$TaskReplannedEventCopyWithImpl<TaskReplannedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskReplannedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskReplanned(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskReplannedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskReplannedEventCopyWith(TaskReplannedEvent value, $Res Function(TaskReplannedEvent) _then) = _$TaskReplannedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskReplannedEventCopyWithImpl<$Res>
    implements $TaskReplannedEventCopyWith<$Res> {
  _$TaskReplannedEventCopyWithImpl(this._self, this._then);

  final TaskReplannedEvent _self;
  final $Res Function(TaskReplannedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskReplannedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskUpdatedEvent extends DomainEvent {
  const TaskUpdatedEvent({required this.taskId}): super._();
  

 final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskUpdatedEventCopyWith<TaskUpdatedEvent> get copyWith => _$TaskUpdatedEventCopyWithImpl<TaskUpdatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskUpdatedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskUpdated(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskUpdatedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskUpdatedEventCopyWith(TaskUpdatedEvent value, $Res Function(TaskUpdatedEvent) _then) = _$TaskUpdatedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskUpdatedEventCopyWithImpl<$Res>
    implements $TaskUpdatedEventCopyWith<$Res> {
  _$TaskUpdatedEventCopyWithImpl(this._self, this._then);

  final TaskUpdatedEvent _self;
  final $Res Function(TaskUpdatedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskUpdatedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskContextChangedEvent extends DomainEvent {
  const TaskContextChangedEvent({required this.taskId, required this.contextState}): super._();
  

 final  TaskId taskId;
 final  String contextState;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskContextChangedEventCopyWith<TaskContextChangedEvent> get copyWith => _$TaskContextChangedEventCopyWithImpl<TaskContextChangedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskContextChangedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.contextState, contextState) || other.contextState == contextState));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,contextState);

@override
String toString() {
  return 'DomainEvent.taskContextChanged(taskId: $taskId, contextState: $contextState)';
}


}

/// @nodoc
abstract mixin class $TaskContextChangedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskContextChangedEventCopyWith(TaskContextChangedEvent value, $Res Function(TaskContextChangedEvent) _then) = _$TaskContextChangedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, String contextState
});




}
/// @nodoc
class _$TaskContextChangedEventCopyWithImpl<$Res>
    implements $TaskContextChangedEventCopyWith<$Res> {
  _$TaskContextChangedEventCopyWithImpl(this._self, this._then);

  final TaskContextChangedEvent _self;
  final $Res Function(TaskContextChangedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? contextState = null,}) {
  return _then(TaskContextChangedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,contextState: null == contextState ? _self.contextState : contextState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TaskMovedEvent extends DomainEvent {
  const TaskMovedEvent({required this.taskId, this.newParentId}): super._();
  

 final  TaskId taskId;
 final  TaskId? newParentId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskMovedEventCopyWith<TaskMovedEvent> get copyWith => _$TaskMovedEventCopyWithImpl<TaskMovedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskMovedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.newParentId, newParentId) || other.newParentId == newParentId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,newParentId);

@override
String toString() {
  return 'DomainEvent.taskMoved(taskId: $taskId, newParentId: $newParentId)';
}


}

/// @nodoc
abstract mixin class $TaskMovedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskMovedEventCopyWith(TaskMovedEvent value, $Res Function(TaskMovedEvent) _then) = _$TaskMovedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, TaskId? newParentId
});




}
/// @nodoc
class _$TaskMovedEventCopyWithImpl<$Res>
    implements $TaskMovedEventCopyWith<$Res> {
  _$TaskMovedEventCopyWithImpl(this._self, this._then);

  final TaskMovedEvent _self;
  final $Res Function(TaskMovedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? newParentId = freezed,}) {
  return _then(TaskMovedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,newParentId: freezed == newParentId ? _self.newParentId : newParentId // ignore: cast_nullable_to_non_nullable
as TaskId?,
  ));
}


}

/// @nodoc


class TaskAliasRenamedEvent extends DomainEvent {
  const TaskAliasRenamedEvent({required this.taskId, this.newAlias}): super._();
  

 final  TaskId taskId;
 final  TaskAlias? newAlias;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskAliasRenamedEventCopyWith<TaskAliasRenamedEvent> get copyWith => _$TaskAliasRenamedEventCopyWithImpl<TaskAliasRenamedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskAliasRenamedEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.newAlias, newAlias) || other.newAlias == newAlias));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,newAlias);

@override
String toString() {
  return 'DomainEvent.taskAliasRenamed(taskId: $taskId, newAlias: $newAlias)';
}


}

/// @nodoc
abstract mixin class $TaskAliasRenamedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskAliasRenamedEventCopyWith(TaskAliasRenamedEvent value, $Res Function(TaskAliasRenamedEvent) _then) = _$TaskAliasRenamedEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId, TaskAlias? newAlias
});




}
/// @nodoc
class _$TaskAliasRenamedEventCopyWithImpl<$Res>
    implements $TaskAliasRenamedEventCopyWith<$Res> {
  _$TaskAliasRenamedEventCopyWithImpl(this._self, this._then);

  final TaskAliasRenamedEvent _self;
  final $Res Function(TaskAliasRenamedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? newAlias = freezed,}) {
  return _then(TaskAliasRenamedEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,newAlias: freezed == newAlias ? _self.newAlias : newAlias // ignore: cast_nullable_to_non_nullable
as TaskAlias?,
  ));
}


}

/// @nodoc


class TaskLinkAddedEvent extends DomainEvent {
  const TaskLinkAddedEvent({required this.fromTaskId, required this.toTaskId, required this.linkType}): super._();
  

 final  TaskId fromTaskId;
 final  TaskId toTaskId;
 final  LinkType linkType;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskLinkAddedEventCopyWith<TaskLinkAddedEvent> get copyWith => _$TaskLinkAddedEventCopyWithImpl<TaskLinkAddedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskLinkAddedEvent&&(identical(other.fromTaskId, fromTaskId) || other.fromTaskId == fromTaskId)&&(identical(other.toTaskId, toTaskId) || other.toTaskId == toTaskId)&&(identical(other.linkType, linkType) || other.linkType == linkType));
}


@override
int get hashCode => Object.hash(runtimeType,fromTaskId,toTaskId,linkType);

@override
String toString() {
  return 'DomainEvent.taskLinkAdded(fromTaskId: $fromTaskId, toTaskId: $toTaskId, linkType: $linkType)';
}


}

/// @nodoc
abstract mixin class $TaskLinkAddedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskLinkAddedEventCopyWith(TaskLinkAddedEvent value, $Res Function(TaskLinkAddedEvent) _then) = _$TaskLinkAddedEventCopyWithImpl;
@useResult
$Res call({
 TaskId fromTaskId, TaskId toTaskId, LinkType linkType
});




}
/// @nodoc
class _$TaskLinkAddedEventCopyWithImpl<$Res>
    implements $TaskLinkAddedEventCopyWith<$Res> {
  _$TaskLinkAddedEventCopyWithImpl(this._self, this._then);

  final TaskLinkAddedEvent _self;
  final $Res Function(TaskLinkAddedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fromTaskId = null,Object? toTaskId = null,Object? linkType = null,}) {
  return _then(TaskLinkAddedEvent(
fromTaskId: null == fromTaskId ? _self.fromTaskId : fromTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,toTaskId: null == toTaskId ? _self.toTaskId : toTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as LinkType,
  ));
}


}

/// @nodoc


class TaskLinkRemovedEvent extends DomainEvent {
  const TaskLinkRemovedEvent({required this.fromTaskId, required this.toTaskId, required this.linkType}): super._();
  

 final  TaskId fromTaskId;
 final  TaskId toTaskId;
 final  LinkType linkType;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskLinkRemovedEventCopyWith<TaskLinkRemovedEvent> get copyWith => _$TaskLinkRemovedEventCopyWithImpl<TaskLinkRemovedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskLinkRemovedEvent&&(identical(other.fromTaskId, fromTaskId) || other.fromTaskId == fromTaskId)&&(identical(other.toTaskId, toTaskId) || other.toTaskId == toTaskId)&&(identical(other.linkType, linkType) || other.linkType == linkType));
}


@override
int get hashCode => Object.hash(runtimeType,fromTaskId,toTaskId,linkType);

@override
String toString() {
  return 'DomainEvent.taskLinkRemoved(fromTaskId: $fromTaskId, toTaskId: $toTaskId, linkType: $linkType)';
}


}

/// @nodoc
abstract mixin class $TaskLinkRemovedEventCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskLinkRemovedEventCopyWith(TaskLinkRemovedEvent value, $Res Function(TaskLinkRemovedEvent) _then) = _$TaskLinkRemovedEventCopyWithImpl;
@useResult
$Res call({
 TaskId fromTaskId, TaskId toTaskId, LinkType linkType
});




}
/// @nodoc
class _$TaskLinkRemovedEventCopyWithImpl<$Res>
    implements $TaskLinkRemovedEventCopyWith<$Res> {
  _$TaskLinkRemovedEventCopyWithImpl(this._self, this._then);

  final TaskLinkRemovedEvent _self;
  final $Res Function(TaskLinkRemovedEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fromTaskId = null,Object? toTaskId = null,Object? linkType = null,}) {
  return _then(TaskLinkRemovedEvent(
fromTaskId: null == fromTaskId ? _self.fromTaskId : fromTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,toTaskId: null == toTaskId ? _self.toTaskId : toTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as LinkType,
  ));
}


}

// dart format on
