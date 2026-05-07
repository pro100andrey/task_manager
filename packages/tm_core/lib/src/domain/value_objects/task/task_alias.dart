import '../../services/task_domain_services.dart';

extension type const TaskAlias._(String value) {
  factory TaskAlias(String value) {
    final normalized = normalizeAlias(value);
    return TaskAlias._(normalized);
  }

  String? get emptyError => value.isEmpty ? 'TaskAlias cannot be empty' : null;

  String? get invalidCharsError {
    final invalid = RegExp(r'[^a-z0-9_\-]');
    return invalid.hasMatch(value)
        ? 'TaskAlias must match ^[a-z0-9_-]+\$: "$value"'
        : null;
  }

  String? get leadingTrailingHyphenError {
    if (value.startsWith('-') || value.endsWith('-')) {
      return 'TaskAlias must not start or end with "-": "$value"';
    }
    return null;
  }

  String? get firstError =>
      emptyError ?? invalidCharsError ?? leadingTrailingHyphenError;
}
