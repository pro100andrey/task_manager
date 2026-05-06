/// Normalizes knowledge entity names.
///
/// Rules:
/// 1. Trim
/// 2. lowercase
/// 3. spaces and '/' -> '-'
/// 4. drop chars outside [a-z0-9_-]
/// 5. trim '-'
/// 6. non-empty
String normalizeKnowledgeName(String raw) {
  var result = raw.trim().toLowerCase();
  result = result.replaceAll(RegExp('[ /]'), '-');
  result = result.replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
  result = result.replaceAll(RegExp(r'^-+|-+$'), '');

  if (result.isEmpty) {
    throw const FormatException('Knowledge name normalizes to empty string');
  }

  return result;
}
