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

 TaskId get id; ProjectId get projectId; TaskTitle get title; TaskStatus get status; TaskContextState get contextState; TaskCompletionPolicy get completionPolicy; int get businessValue; int get urgencyScore; TaskLastActionType get lastActionType; DateTime get lastProgressAt; DateTime get createdAt; DateTime get updatedAt; List<String> get tags; Map<String, dynamic> get metadata; int get planVersion; TaskId? get parentId; TaskAlias? get alias; TaskDescription? get description; String? get statusReason; double? get estimatedEffort; DateTime? get dueDate; String? get assignedTo; DateTime? get completedAt;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.contextState, contextState) || other.contextState == contextState)&&(identical(other.completionPolicy, completionPolicy) || other.completionPolicy == completionPolicy)&&(identical(other.businessValue, businessValue) || other.businessValue == businessValue)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.lastActionType, lastActionType) || other.lastActionType == lastActionType)&&(identical(other.lastProgressAt, lastProgressAt) || other.lastProgressAt == lastProgressAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.planVersion, planVersion) || other.planVersion == planVersion)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.description, description) || other.description == description)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.estimatedEffort, estimatedEffort) || other.estimatedEffort == estimatedEffort)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,title,status,contextState,completionPolicy,businessValue,urgencyScore,lastActionType,lastProgressAt,createdAt,updatedAt,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(metadata),planVersion,parentId,alias,description,statusReason,estimatedEffort,dueDate,assignedTo,completedAt]);

@override
String toString() {
  return 'Task(id: $id, projectId: $projectId, title: $title, status: $status, contextState: $contextState, completionPolicy: $completionPolicy, businessValue: $businessValue, urgencyScore: $urgencyScore, lastActionType: $lastActionType, lastProgressAt: $lastProgressAt, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, metadata: $metadata, planVersion: $planVersion, parentId: $parentId, alias: $alias, description: $description, statusReason: $statusReason, estimatedEffort: $estimatedEffort, dueDate: $dueDate, assignedTo: $assignedTo, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 TaskId id, ProjectId projectId, TaskTitle title, TaskStatus status, TaskContextState contextState, TaskCompletionPolicy completionPolicy, int businessValue, int urgencyScore, TaskLastActionType lastActionType, DateTime lastProgressAt, DateTime createdAt, DateTime updatedAt, List<String> tags, Map<String, dynamic> metadata, int planVersion, TaskId? parentId, TaskAlias? alias, TaskDescription? description, String? statusReason, double? estimatedEffort, DateTime? dueDate, String? assignedTo, DateTime? completedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? title = null,Object? status = null,Object? contextState = null,Object? completionPolicy = null,Object? businessValue = null,Object? urgencyScore = null,Object? lastActionType = null,Object? lastProgressAt = null,Object? createdAt = null,Object? updatedAt = null,Object? tags = null,Object? metadata = null,Object? planVersion = null,Object? parentId = freezed,Object? alias = freezed,Object? description = freezed,Object? statusReason = freezed,Object? estimatedEffort = freezed,Object? dueDate = freezed,Object? assignedTo = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TaskId,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as ProjectId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as TaskTitle,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,contextState: null == contextState ? _self.contextState : contextState // ignore: cast_nullable_to_non_nullable
as TaskContextState,completionPolicy: null == completionPolicy ? _self.completionPolicy : completionPolicy // ignore: cast_nullable_to_non_nullable
as TaskCompletionPolicy,businessValue: null == businessValue ? _self.businessValue : businessValue // ignore: cast_nullable_to_non_nullable
as int,urgencyScore: null == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as int,lastActionType: null == lastActionType ? _self.lastActionType : lastActionType // ignore: cast_nullable_to_non_nullable
as TaskLastActionType,lastProgressAt: null == lastProgressAt ? _self.lastProgressAt : lastProgressAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,planVersion: null == planVersion ? _self.planVersion : planVersion // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TaskId?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as TaskAlias?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as TaskDescription?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,estimatedEffort: freezed == estimatedEffort ? _self.estimatedEffort : estimatedEffort // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}



/// @nodoc


class _Task implements Task {
  const _Task({required this.id, required this.projectId, required this.title, required this.status, required this.contextState, required this.completionPolicy, required this.businessValue, required this.urgencyScore, required this.lastActionType, required this.lastProgressAt, required this.createdAt, required this.updatedAt, required final  List<String> tags, required final  Map<String, dynamic> metadata, required this.planVersion, this.parentId, this.alias, this.description, this.statusReason, this.estimatedEffort, this.dueDate, this.assignedTo, this.completedAt}): _tags = tags,_metadata = metadata;
  

@override final  TaskId id;
@override final  ProjectId projectId;
@override final  TaskTitle title;
@override final  TaskStatus status;
@override final  TaskContextState contextState;
@override final  TaskCompletionPolicy completionPolicy;
@override final  int businessValue;
@override final  int urgencyScore;
@override final  TaskLastActionType lastActionType;
@override final  DateTime lastProgressAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  Map<String, dynamic> _metadata;
@override Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override final  int planVersion;
@override final  TaskId? parentId;
@override final  TaskAlias? alias;
@override final  TaskDescription? description;
@override final  String? statusReason;
@override final  double? estimatedEffort;
@override final  DateTime? dueDate;
@override final  String? assignedTo;
@override final  DateTime? completedAt;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.contextState, contextState) || other.contextState == contextState)&&(identical(other.completionPolicy, completionPolicy) || other.completionPolicy == completionPolicy)&&(identical(other.businessValue, businessValue) || other.businessValue == businessValue)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.lastActionType, lastActionType) || other.lastActionType == lastActionType)&&(identical(other.lastProgressAt, lastProgressAt) || other.lastProgressAt == lastProgressAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.planVersion, planVersion) || other.planVersion == planVersion)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.description, description) || other.description == description)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.estimatedEffort, estimatedEffort) || other.estimatedEffort == estimatedEffort)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,title,status,contextState,completionPolicy,businessValue,urgencyScore,lastActionType,lastProgressAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_metadata),planVersion,parentId,alias,description,statusReason,estimatedEffort,dueDate,assignedTo,completedAt]);

@override
String toString() {
  return 'Task(id: $id, projectId: $projectId, title: $title, status: $status, contextState: $contextState, completionPolicy: $completionPolicy, businessValue: $businessValue, urgencyScore: $urgencyScore, lastActionType: $lastActionType, lastProgressAt: $lastProgressAt, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, metadata: $metadata, planVersion: $planVersion, parentId: $parentId, alias: $alias, description: $description, statusReason: $statusReason, estimatedEffort: $estimatedEffort, dueDate: $dueDate, assignedTo: $assignedTo, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 TaskId id, ProjectId projectId, TaskTitle title, TaskStatus status, TaskContextState contextState, TaskCompletionPolicy completionPolicy, int businessValue, int urgencyScore, TaskLastActionType lastActionType, DateTime lastProgressAt, DateTime createdAt, DateTime updatedAt, List<String> tags, Map<String, dynamic> metadata, int planVersion, TaskId? parentId, TaskAlias? alias, TaskDescription? description, String? statusReason, double? estimatedEffort, DateTime? dueDate, String? assignedTo, DateTime? completedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? title = null,Object? status = null,Object? contextState = null,Object? completionPolicy = null,Object? businessValue = null,Object? urgencyScore = null,Object? lastActionType = null,Object? lastProgressAt = null,Object? createdAt = null,Object? updatedAt = null,Object? tags = null,Object? metadata = null,Object? planVersion = null,Object? parentId = freezed,Object? alias = freezed,Object? description = freezed,Object? statusReason = freezed,Object? estimatedEffort = freezed,Object? dueDate = freezed,Object? assignedTo = freezed,Object? completedAt = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TaskId,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as ProjectId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as TaskTitle,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,contextState: null == contextState ? _self.contextState : contextState // ignore: cast_nullable_to_non_nullable
as TaskContextState,completionPolicy: null == completionPolicy ? _self.completionPolicy : completionPolicy // ignore: cast_nullable_to_non_nullable
as TaskCompletionPolicy,businessValue: null == businessValue ? _self.businessValue : businessValue // ignore: cast_nullable_to_non_nullable
as int,urgencyScore: null == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as int,lastActionType: null == lastActionType ? _self.lastActionType : lastActionType // ignore: cast_nullable_to_non_nullable
as TaskLastActionType,lastProgressAt: null == lastProgressAt ? _self.lastProgressAt : lastProgressAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,planVersion: null == planVersion ? _self.planVersion : planVersion // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TaskId?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as TaskAlias?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as TaskDescription?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,estimatedEffort: freezed == estimatedEffort ? _self.estimatedEffort : estimatedEffort // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
