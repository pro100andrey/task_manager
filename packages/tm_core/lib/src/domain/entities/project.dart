import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/project/project_description.dart';
import '../value_objects/project/project_id.dart';
import '../value_objects/project/project_name.dart';

part 'project.freezed.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required ProjectId id,
    required ProjectName name,
    required DateTime createdAt,
    ProjectDescription? description,
  }) = _Project;
}
