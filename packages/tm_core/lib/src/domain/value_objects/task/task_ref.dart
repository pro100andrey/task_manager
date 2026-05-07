import '../value_objects.dart';
import 'task_alias.dart';

sealed class TaskRef {
  const TaskRef();

  factory TaskRef.id(TaskId id) = TaskIdRef;

  factory TaskRef.alias(TaskAlias alias) = TaskAliasRef;

  @override
  String toString() => switch (this) {
    TaskIdRef(:final id) => 'Task ID: $id',
    TaskAliasRef(:final alias) => 'Task Alias: $alias',
  };

  bool get isId => this is TaskIdRef;

  bool get isAlias => this is TaskAliasRef;

  String get value => switch (this) {
    TaskIdRef(:final id) => id.value,
    TaskAliasRef(:final alias) => alias.value,
  };
}

class TaskIdRef extends TaskRef {
  const TaskIdRef(this.id);

  final TaskId id;
}

class TaskAliasRef extends TaskRef {
  const TaskAliasRef(this.alias);

  final TaskAlias alias;
}
