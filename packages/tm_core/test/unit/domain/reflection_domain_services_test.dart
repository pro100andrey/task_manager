import 'package:test/test.dart';
import 'package:tm_core/src/domain/enums/task_last_action_type.dart';
import 'package:tm_core/src/domain/exceptions/reflection_exceptions.dart';
import 'package:tm_core/src/domain/services/reflection_domain_services.dart';
import 'package:tm_core/src/domain/value_objects/reflection/reflection_id.dart';

void main() {
  group('ReflectionId', () {
    test('accepts generated UUIDv7', () {
      final id = ReflectionId.generate();
      expect(id.raw, hasLength(36));
      expect(id.raw[14], '7');
    });

    test('rejects invalid UUID', () {
      expect(
        const ReflectionId('bad-id').formatError,
        contains('Invalid UUID(v7) format for ReflectionId: bad-id'),
      );
    });
  });

  group('ensureReflectionBudgetAvailable', () {
    test('allows reflection below budget', () {
      expect(
        () => ensureReflectionBudgetAvailable(
          existingReflections: 2,
          reflectionBudget: 3,
        ),
        returnsNormally,
      );
    });

    test('throws when budget is exhausted', () {
      expect(
        () => ensureReflectionBudgetAvailable(
          existingReflections: 3,
          reflectionBudget: 3,
        ),
        throwsA(isA<RecursiveReflectionWarning>()),
      );
    });
  });

  group('checkPNR', () {
    test('does not throw when created count is small', () {
      expect(
        () => checkPNR(
          const PnrHistorySnapshot(
            deltaCompleted: 0,
            deltaCreated: 5,
            recentActions: [TaskLastActionType.planning],
          ),
        ),
        returnsNormally,
      );
    });

    test('throws when ratio falls below threshold after many creates', () {
      expect(
        () => checkPNR(
          const PnrHistorySnapshot(
            deltaCompleted: 0,
            deltaCreated: 6,
            recentActions: [TaskLastActionType.execution],
          ),
        ),
        throwsA(isA<StallDetectedException>()),
      );
    });

    test('throws on three consecutive planning or reflection actions', () {
      expect(
        () => checkPNR(
          const PnrHistorySnapshot(
            deltaCompleted: 1,
            deltaCreated: 1,
            recentActions: [
              TaskLastActionType.planning,
              TaskLastActionType.reflection,
              TaskLastActionType.planning,
            ],
          ),
        ),
        throwsA(isA<StallDetectedException>()),
      );
    });

    test('does not throw when recent actions include execution', () {
      expect(
        () => checkPNR(
          const PnrHistorySnapshot(
            deltaCompleted: 1,
            deltaCreated: 6,
            recentActions: [
              TaskLastActionType.planning,
              TaskLastActionType.execution,
              TaskLastActionType.reflection,
            ],
          ),
        ),
        returnsNormally,
      );
    });
  });
}
