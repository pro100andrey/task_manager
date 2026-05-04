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

// dart format on
