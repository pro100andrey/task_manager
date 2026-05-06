import 'package:test/test.dart';
import 'package:tm_core/tm_core.dart';

void main() {
  group('normalizeKnowledgeName', () {
    test('normalizes mixed input', () {
      final out = normalizeKnowledgeName('  My Fact/Name #1  ');
      expect(out, 'my-fact-name-1');
    });

    test('throws when normalizes to empty', () {
      expect(() => normalizeKnowledgeName('!!!'), throwsFormatException);
    });
  });

  group('KnowledgeEntityId', () {
    test('generate returns valid id', () {
      expect(KnowledgeEntityId.generate, returnsNormally);
    });

    test('rejects non-v7 uuid', () {
      expect(
        () => KnowledgeEntityId('123e4567-e89b-12d3-a456-426614174000'),
        throwsFormatException,
      );
    });
  });
}
