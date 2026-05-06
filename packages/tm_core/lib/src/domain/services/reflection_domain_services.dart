import '../enums/task_last_action_type.dart';
import '../exceptions/reflection_exceptions.dart';

const defaultReflectionBudget = 3;

class PnrHistorySnapshot {
  const PnrHistorySnapshot({
    required this.deltaCompleted,
    required this.deltaCreated,
    required this.recentActions,
  });

  final int deltaCompleted;
  final int deltaCreated;
  final List<TaskLastActionType> recentActions;
}

void ensureReflectionBudgetAvailable({
  required int existingReflections,
  required int reflectionBudget,
}) {
  if (existingReflections >= reflectionBudget) {
    throw const RecursiveReflectionWarning(
      'Reflection budget exhausted. '
      'Complete execution before reflecting again.',
    );
  }
}

void checkPNR(PnrHistorySnapshot snapshot) {
  if (snapshot.deltaCreated > 5) {
    final ratio = snapshot.deltaCompleted / snapshot.deltaCreated;
    if (ratio < 0.15) {
      throw const StallDetectedException(
        'Too many plans without execution. Complete tasks first.',
      );
    }
  }

  if (snapshot.recentActions.length >= 3) {
    final recentThree = snapshot.recentActions.take(3);
    final allPlanningLike = recentThree.every(
      (action) =>
          action == TaskLastActionType.planning ||
          action == TaskLastActionType.reflection,
    );
    if (allPlanningLike) {
      throw const StallDetectedException(
        'Consecutive planning without execution detected.',
      );
    }
  }
}
