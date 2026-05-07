import '../../services/task_domain_services.dart';

extension type const TaskAlias._(({String raw, String normalized}) data) {
  factory TaskAlias(String value) {
    final normalized = normalizeAlias(value);
    return TaskAlias._((raw: value, normalized: normalized));
  }

  String get value => data.raw;

  String get normalized => data.normalized;

  String? get emptyError =>
      data.raw.isEmpty ? 'TaskAlias cannot be empty' : null;

  String? get invalidCharsError {
    final invalid = RegExp(r'[^a-z0-9_\-]');
    return invalid.hasMatch(data.raw)
        ? 'TaskAlias must match ^[a-z0-9_-]+\$: "${data.normalized}"'
        : null;
  }

  String? get leadingTrailingHyphenError {
    if (data.raw.startsWith('-') || data.raw.endsWith('-')) {
      return 'TaskAlias must not start or end with "-": "${data.normalized}"';
    }
    return null;
  }

  String? get firstError =>
      emptyError ?? invalidCharsError ?? leadingTrailingHyphenError;
}
