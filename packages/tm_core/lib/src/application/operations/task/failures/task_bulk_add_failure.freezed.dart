// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_bulk_add_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskBulkAddFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskBulkAddFailure()';
}


}

/// @nodoc
class $TaskBulkAddFailureCopyWith<$Res>  {
$TaskBulkAddFailureCopyWith(TaskBulkAddFailure _, $Res Function(TaskBulkAddFailure) __);
}



/// @nodoc


class TaskBulkAddValidationError implements TaskBulkAddFailure {
  const TaskBulkAddValidationError(this.message);
  

 final  String message;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBulkAddValidationErrorCopyWith<TaskBulkAddValidationError> get copyWith => _$TaskBulkAddValidationErrorCopyWithImpl<TaskBulkAddValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddValidationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TaskBulkAddFailure.validationError(message: $message)';
}


}

/// @nodoc
abstract mixin class $TaskBulkAddValidationErrorCopyWith<$Res> implements $TaskBulkAddFailureCopyWith<$Res> {
  factory $TaskBulkAddValidationErrorCopyWith(TaskBulkAddValidationError value, $Res Function(TaskBulkAddValidationError) _then) = _$TaskBulkAddValidationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TaskBulkAddValidationErrorCopyWithImpl<$Res>
    implements $TaskBulkAddValidationErrorCopyWith<$Res> {
  _$TaskBulkAddValidationErrorCopyWithImpl(this._self, this._then);

  final TaskBulkAddValidationError _self;
  final $Res Function(TaskBulkAddValidationError) _then;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TaskBulkAddValidationError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TaskBulkAddProjectNotFound implements TaskBulkAddFailure {
  const TaskBulkAddProjectNotFound(this.projectId);
  

 final  String projectId;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBulkAddProjectNotFoundCopyWith<TaskBulkAddProjectNotFound> get copyWith => _$TaskBulkAddProjectNotFoundCopyWithImpl<TaskBulkAddProjectNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddProjectNotFound&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,projectId);

@override
String toString() {
  return 'TaskBulkAddFailure.projectNotFound(projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $TaskBulkAddProjectNotFoundCopyWith<$Res> implements $TaskBulkAddFailureCopyWith<$Res> {
  factory $TaskBulkAddProjectNotFoundCopyWith(TaskBulkAddProjectNotFound value, $Res Function(TaskBulkAddProjectNotFound) _then) = _$TaskBulkAddProjectNotFoundCopyWithImpl;
@useResult
$Res call({
 String projectId
});




}
/// @nodoc
class _$TaskBulkAddProjectNotFoundCopyWithImpl<$Res>
    implements $TaskBulkAddProjectNotFoundCopyWith<$Res> {
  _$TaskBulkAddProjectNotFoundCopyWithImpl(this._self, this._then);

  final TaskBulkAddProjectNotFound _self;
  final $Res Function(TaskBulkAddProjectNotFound) _then;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,}) {
  return _then(TaskBulkAddProjectNotFound(
null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TaskBulkAddParentNotFound implements TaskBulkAddFailure {
  const TaskBulkAddParentNotFound(this.parentId);
  

 final  String parentId;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBulkAddParentNotFoundCopyWith<TaskBulkAddParentNotFound> get copyWith => _$TaskBulkAddParentNotFoundCopyWithImpl<TaskBulkAddParentNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddParentNotFound&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,parentId);

@override
String toString() {
  return 'TaskBulkAddFailure.parentNotFound(parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $TaskBulkAddParentNotFoundCopyWith<$Res> implements $TaskBulkAddFailureCopyWith<$Res> {
  factory $TaskBulkAddParentNotFoundCopyWith(TaskBulkAddParentNotFound value, $Res Function(TaskBulkAddParentNotFound) _then) = _$TaskBulkAddParentNotFoundCopyWithImpl;
@useResult
$Res call({
 String parentId
});




}
/// @nodoc
class _$TaskBulkAddParentNotFoundCopyWithImpl<$Res>
    implements $TaskBulkAddParentNotFoundCopyWith<$Res> {
  _$TaskBulkAddParentNotFoundCopyWithImpl(this._self, this._then);

  final TaskBulkAddParentNotFound _self;
  final $Res Function(TaskBulkAddParentNotFound) _then;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? parentId = null,}) {
  return _then(TaskBulkAddParentNotFound(
null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TaskBulkAddTaskCreationFailed implements TaskBulkAddFailure {
  const TaskBulkAddTaskCreationFailed(this.taskIndex, this.message);
  

 final  int taskIndex;
 final  String message;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBulkAddTaskCreationFailedCopyWith<TaskBulkAddTaskCreationFailed> get copyWith => _$TaskBulkAddTaskCreationFailedCopyWithImpl<TaskBulkAddTaskCreationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddTaskCreationFailed&&(identical(other.taskIndex, taskIndex) || other.taskIndex == taskIndex)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,taskIndex,message);

@override
String toString() {
  return 'TaskBulkAddFailure.taskCreationFailed(taskIndex: $taskIndex, message: $message)';
}


}

/// @nodoc
abstract mixin class $TaskBulkAddTaskCreationFailedCopyWith<$Res> implements $TaskBulkAddFailureCopyWith<$Res> {
  factory $TaskBulkAddTaskCreationFailedCopyWith(TaskBulkAddTaskCreationFailed value, $Res Function(TaskBulkAddTaskCreationFailed) _then) = _$TaskBulkAddTaskCreationFailedCopyWithImpl;
@useResult
$Res call({
 int taskIndex, String message
});




}
/// @nodoc
class _$TaskBulkAddTaskCreationFailedCopyWithImpl<$Res>
    implements $TaskBulkAddTaskCreationFailedCopyWith<$Res> {
  _$TaskBulkAddTaskCreationFailedCopyWithImpl(this._self, this._then);

  final TaskBulkAddTaskCreationFailed _self;
  final $Res Function(TaskBulkAddTaskCreationFailed) _then;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskIndex = null,Object? message = null,}) {
  return _then(TaskBulkAddTaskCreationFailed(
null == taskIndex ? _self.taskIndex : taskIndex // ignore: cast_nullable_to_non_nullable
as int,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TaskBulkAddTooManyTasks implements TaskBulkAddFailure {
  const TaskBulkAddTooManyTasks(this.count, this.maxCount);
  

 final  int count;
 final  int maxCount;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBulkAddTooManyTasksCopyWith<TaskBulkAddTooManyTasks> get copyWith => _$TaskBulkAddTooManyTasksCopyWithImpl<TaskBulkAddTooManyTasks>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBulkAddTooManyTasks&&(identical(other.count, count) || other.count == count)&&(identical(other.maxCount, maxCount) || other.maxCount == maxCount));
}


@override
int get hashCode => Object.hash(runtimeType,count,maxCount);

@override
String toString() {
  return 'TaskBulkAddFailure.tooManyTasks(count: $count, maxCount: $maxCount)';
}


}

/// @nodoc
abstract mixin class $TaskBulkAddTooManyTasksCopyWith<$Res> implements $TaskBulkAddFailureCopyWith<$Res> {
  factory $TaskBulkAddTooManyTasksCopyWith(TaskBulkAddTooManyTasks value, $Res Function(TaskBulkAddTooManyTasks) _then) = _$TaskBulkAddTooManyTasksCopyWithImpl;
@useResult
$Res call({
 int count, int maxCount
});




}
/// @nodoc
class _$TaskBulkAddTooManyTasksCopyWithImpl<$Res>
    implements $TaskBulkAddTooManyTasksCopyWith<$Res> {
  _$TaskBulkAddTooManyTasksCopyWithImpl(this._self, this._then);

  final TaskBulkAddTooManyTasks _self;
  final $Res Function(TaskBulkAddTooManyTasks) _then;

/// Create a copy of TaskBulkAddFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,Object? maxCount = null,}) {
  return _then(TaskBulkAddTooManyTasks(
null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,null == maxCount ? _self.maxCount : maxCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
