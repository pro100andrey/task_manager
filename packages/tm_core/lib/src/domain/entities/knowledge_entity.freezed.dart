// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'knowledge_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KnowledgeEntity {

 KnowledgeEntityId get id; ProjectId get projectId; String get name; String get normalizedName; KnowledgeEntityType get entityType; String get content; Map<String, dynamic> get metadata; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of KnowledgeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnowledgeEntityCopyWith<KnowledgeEntity> get copyWith => _$KnowledgeEntityCopyWithImpl<KnowledgeEntity>(this as KnowledgeEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnowledgeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.normalizedName, normalizedName) || other.normalizedName == normalizedName)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,normalizedName,entityType,content,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'KnowledgeEntity(id: $id, projectId: $projectId, name: $name, normalizedName: $normalizedName, entityType: $entityType, content: $content, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $KnowledgeEntityCopyWith<$Res>  {
  factory $KnowledgeEntityCopyWith(KnowledgeEntity value, $Res Function(KnowledgeEntity) _then) = _$KnowledgeEntityCopyWithImpl;
@useResult
$Res call({
 KnowledgeEntityId id, ProjectId projectId, String name, String normalizedName, KnowledgeEntityType entityType, String content, Map<String, dynamic> metadata, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$KnowledgeEntityCopyWithImpl<$Res>
    implements $KnowledgeEntityCopyWith<$Res> {
  _$KnowledgeEntityCopyWithImpl(this._self, this._then);

  final KnowledgeEntity _self;
  final $Res Function(KnowledgeEntity) _then;

/// Create a copy of KnowledgeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? name = null,Object? normalizedName = null,Object? entityType = null,Object? content = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as KnowledgeEntityId,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as ProjectId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,normalizedName: null == normalizedName ? _self.normalizedName : normalizedName // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as KnowledgeEntityType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}



/// @nodoc


class _KnowledgeEntity implements KnowledgeEntity {
  const _KnowledgeEntity({required this.id, required this.projectId, required this.name, required this.normalizedName, required this.entityType, required this.content, required final  Map<String, dynamic> metadata, required this.createdAt, required this.updatedAt}): _metadata = metadata;
  

@override final  KnowledgeEntityId id;
@override final  ProjectId projectId;
@override final  String name;
@override final  String normalizedName;
@override final  KnowledgeEntityType entityType;
@override final  String content;
 final  Map<String, dynamic> _metadata;
@override Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of KnowledgeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnowledgeEntityCopyWith<_KnowledgeEntity> get copyWith => __$KnowledgeEntityCopyWithImpl<_KnowledgeEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KnowledgeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.normalizedName, normalizedName) || other.normalizedName == normalizedName)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,normalizedName,entityType,content,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'KnowledgeEntity(id: $id, projectId: $projectId, name: $name, normalizedName: $normalizedName, entityType: $entityType, content: $content, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$KnowledgeEntityCopyWith<$Res> implements $KnowledgeEntityCopyWith<$Res> {
  factory _$KnowledgeEntityCopyWith(_KnowledgeEntity value, $Res Function(_KnowledgeEntity) _then) = __$KnowledgeEntityCopyWithImpl;
@override @useResult
$Res call({
 KnowledgeEntityId id, ProjectId projectId, String name, String normalizedName, KnowledgeEntityType entityType, String content, Map<String, dynamic> metadata, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$KnowledgeEntityCopyWithImpl<$Res>
    implements _$KnowledgeEntityCopyWith<$Res> {
  __$KnowledgeEntityCopyWithImpl(this._self, this._then);

  final _KnowledgeEntity _self;
  final $Res Function(_KnowledgeEntity) _then;

/// Create a copy of KnowledgeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? name = null,Object? normalizedName = null,Object? entityType = null,Object? content = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_KnowledgeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as KnowledgeEntityId,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as ProjectId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,normalizedName: null == normalizedName ? _self.normalizedName : normalizedName // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as KnowledgeEntityType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
