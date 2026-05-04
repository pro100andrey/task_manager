import 'package:test/test.dart';
import 'package:tm_core/src/domain/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess is true', () {
        const r = Success<int, String>(42);
        expect(r.isSuccess, isTrue);
        expect(r.isFailure, isFalse);
      });

      test('fold calls onSuccess', () {
        const r = Success<int, String>(7);
        final out = r.fold(onSuccess: (v) => v * 2, onFailure: (_) => -1);
        expect(out, 14);
      });

      test('value is accessible', () {
        expect(const Success<String, int>('ok').value, 'ok');
      });
    });

    group('Failure', () {
      test('isFailure is true', () {
        const r = Failure<int, String>('err');
        expect(r.isFailure, isTrue);
        expect(r.isSuccess, isFalse);
      });

      test('fold calls onFailure', () {
        const r = Failure<int, String>('oops');
        final out = r.fold(onSuccess: (_) => 0, onFailure: (e) => e.length);
        expect(out, 4);
      });

      test('error is accessible', () {
        expect(const Failure<int, String>('bad').error, 'bad');
      });
    });

    test('switch pattern matching works', () {
      const Result<int, String> r = Success(1);
      switch (r) {
        case Success(:final value):
          expect(value, 1);
        case Failure(:final error):
          fail('Should not be failure: $error');
      }
    });
  });
}
