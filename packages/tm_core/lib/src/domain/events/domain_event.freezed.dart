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

 TaskId get taskId;
/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainEventCopyWith<DomainEvent> get copyWith => _$DomainEventCopyWithImpl<DomainEvent>(this as DomainEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $DomainEventCopyWith<$Res>  {
  factory $DomainEventCopyWith(DomainEvent value, $Res Function(DomainEvent) _then) = _$DomainEventCopyWithImpl;
@useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$DomainEventCopyWithImpl<$Res>
    implements $DomainEventCopyWith<$Res> {
  _$DomainEventCopyWithImpl(this._self, this._then);

  final DomainEvent _self;
  final $Res Function(DomainEvent) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}

}



/// @nodoc


class TaskCreated extends DomainEvent {
  const TaskCreated({required this.taskId}): super._();
  

@override final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCreatedCopyWith<TaskCreated> get copyWith => _$TaskCreatedCopyWithImpl<TaskCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCreated&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskCreated(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskCreatedCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskCreatedCopyWith(TaskCreated value, $Res Function(TaskCreated) _then) = _$TaskCreatedCopyWithImpl;
@override @useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskCreatedCopyWithImpl<$Res>
    implements $TaskCreatedCopyWith<$Res> {
  _$TaskCreatedCopyWithImpl(this._self, this._then);

  final TaskCreated _self;
  final $Res Function(TaskCreated) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskCreated(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskCompleted extends DomainEvent {
  const TaskCompleted({required this.taskId}): super._();
  

@override final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCompletedCopyWith<TaskCompleted> get copyWith => _$TaskCompletedCopyWithImpl<TaskCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCompleted&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskCompleted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskCompletedCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskCompletedCopyWith(TaskCompleted value, $Res Function(TaskCompleted) _then) = _$TaskCompletedCopyWithImpl;
@override @useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskCompletedCopyWithImpl<$Res>
    implements $TaskCompletedCopyWith<$Res> {
  _$TaskCompletedCopyWithImpl(this._self, this._then);

  final TaskCompleted _self;
  final $Res Function(TaskCompleted) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskCompleted(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

/// @nodoc


class TaskReplanned extends DomainEvent {
  const TaskReplanned({required this.taskId}): super._();
  

@override final  TaskId taskId;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskReplannedCopyWith<TaskReplanned> get copyWith => _$TaskReplannedCopyWithImpl<TaskReplanned>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskReplanned&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'DomainEvent.taskReplanned(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $TaskReplannedCopyWith<$Res> implements $DomainEventCopyWith<$Res> {
  factory $TaskReplannedCopyWith(TaskReplanned value, $Res Function(TaskReplanned) _then) = _$TaskReplannedCopyWithImpl;
@override @useResult
$Res call({
 TaskId taskId
});




}
/// @nodoc
class _$TaskReplannedCopyWithImpl<$Res>
    implements $TaskReplannedCopyWith<$Res> {
  _$TaskReplannedCopyWithImpl(this._self, this._then);

  final TaskReplanned _self;
  final $Res Function(TaskReplanned) _then;

/// Create a copy of DomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(TaskReplanned(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as TaskId,
  ));
}


}

// dart format on
