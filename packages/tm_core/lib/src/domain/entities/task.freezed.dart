// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Task {

 TaskId get id; TaskTitle get title; TaskStatus get status; TaskId? get parentId; TaskDescription? get description;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,status,parentId,description);

@override
String toString() {
  return 'Task(id: $id, title: $title, status: $status, parentId: $parentId, description: $description)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 TaskId id, TaskTitle title, TaskStatus status, TaskId? parentId, TaskDescription? description
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? parentId = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TaskId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as TaskTitle,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TaskId?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as TaskDescription?,
  ));
}

}



/// @nodoc


class _Task implements Task {
  const _Task({required this.id, required this.title, required this.status, this.parentId, this.description});
  

@override final  TaskId id;
@override final  TaskTitle title;
@override final  TaskStatus status;
@override final  TaskId? parentId;
@override final  TaskDescription? description;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,status,parentId,description);

@override
String toString() {
  return 'Task(id: $id, title: $title, status: $status, parentId: $parentId, description: $description)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 TaskId id, TaskTitle title, TaskStatus status, TaskId? parentId, TaskDescription? description
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? parentId = freezed,Object? description = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TaskId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as TaskTitle,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TaskId?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as TaskDescription?,
  ));
}


}

// dart format on
