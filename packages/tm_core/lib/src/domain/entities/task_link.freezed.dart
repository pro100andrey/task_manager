// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskLink {

 String get id; TaskId get fromTaskId; TaskId get toTaskId; LinkType get linkType; DateTime get createdAt; String? get label;
/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskLinkCopyWith<TaskLink> get copyWith => _$TaskLinkCopyWithImpl<TaskLink>(this as TaskLink, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskLink&&(identical(other.id, id) || other.id == id)&&(identical(other.fromTaskId, fromTaskId) || other.fromTaskId == fromTaskId)&&(identical(other.toTaskId, toTaskId) || other.toTaskId == toTaskId)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,id,fromTaskId,toTaskId,linkType,createdAt,label);

@override
String toString() {
  return 'TaskLink(id: $id, fromTaskId: $fromTaskId, toTaskId: $toTaskId, linkType: $linkType, createdAt: $createdAt, label: $label)';
}


}

/// @nodoc
abstract mixin class $TaskLinkCopyWith<$Res>  {
  factory $TaskLinkCopyWith(TaskLink value, $Res Function(TaskLink) _then) = _$TaskLinkCopyWithImpl;
@useResult
$Res call({
 String id, TaskId fromTaskId, TaskId toTaskId, LinkType linkType, DateTime createdAt, String? label
});




}
/// @nodoc
class _$TaskLinkCopyWithImpl<$Res>
    implements $TaskLinkCopyWith<$Res> {
  _$TaskLinkCopyWithImpl(this._self, this._then);

  final TaskLink _self;
  final $Res Function(TaskLink) _then;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromTaskId = null,Object? toTaskId = null,Object? linkType = null,Object? createdAt = null,Object? label = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromTaskId: null == fromTaskId ? _self.fromTaskId : fromTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,toTaskId: null == toTaskId ? _self.toTaskId : toTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as LinkType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _TaskLink implements TaskLink {
  const _TaskLink({required this.id, required this.fromTaskId, required this.toTaskId, required this.linkType, required this.createdAt, this.label});
  

@override final  String id;
@override final  TaskId fromTaskId;
@override final  TaskId toTaskId;
@override final  LinkType linkType;
@override final  DateTime createdAt;
@override final  String? label;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskLinkCopyWith<_TaskLink> get copyWith => __$TaskLinkCopyWithImpl<_TaskLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskLink&&(identical(other.id, id) || other.id == id)&&(identical(other.fromTaskId, fromTaskId) || other.fromTaskId == fromTaskId)&&(identical(other.toTaskId, toTaskId) || other.toTaskId == toTaskId)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,id,fromTaskId,toTaskId,linkType,createdAt,label);

@override
String toString() {
  return 'TaskLink(id: $id, fromTaskId: $fromTaskId, toTaskId: $toTaskId, linkType: $linkType, createdAt: $createdAt, label: $label)';
}


}

/// @nodoc
abstract mixin class _$TaskLinkCopyWith<$Res> implements $TaskLinkCopyWith<$Res> {
  factory _$TaskLinkCopyWith(_TaskLink value, $Res Function(_TaskLink) _then) = __$TaskLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, TaskId fromTaskId, TaskId toTaskId, LinkType linkType, DateTime createdAt, String? label
});




}
/// @nodoc
class __$TaskLinkCopyWithImpl<$Res>
    implements _$TaskLinkCopyWith<$Res> {
  __$TaskLinkCopyWithImpl(this._self, this._then);

  final _TaskLink _self;
  final $Res Function(_TaskLink) _then;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromTaskId = null,Object? toTaskId = null,Object? linkType = null,Object? createdAt = null,Object? label = freezed,}) {
  return _then(_TaskLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromTaskId: null == fromTaskId ? _self.fromTaskId : fromTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,toTaskId: null == toTaskId ? _self.toTaskId : toTaskId // ignore: cast_nullable_to_non_nullable
as TaskId,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as LinkType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
