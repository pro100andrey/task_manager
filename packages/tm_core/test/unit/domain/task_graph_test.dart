import 'package:test/test.dart';
import 'package:tm_core/src/domain/exceptions/cycle_exception.dart';
import 'package:tm_core/src/domain/services/task_graph.dart';

void main() {
  // ---------------------------------------------------------------------------
  // detectCycle
  // ---------------------------------------------------------------------------
  group('detectCycle', () {
    test('no exception on empty graph', () {
      expect(() => detectCycle({}), returnsNormally);
    });

    test('no exception on linear chain A→B→C', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      expect(() => detectCycle(adj), returnsNormally);
    });

    test('no exception on parallel paths A→C and B→C', () {
      final adj = {
        'A': ['C'],
        'B': ['C'],
      };
      expect(() => detectCycle(adj), returnsNormally);
    });

    test('throws CycleException on direct cycle A→B→A', () {
      final adj = {
        'A': ['B'],
        'B': ['A'],
      };
      expect(() => detectCycle(adj), throwsA(isA<CycleException>()));
    });

    test('throws CycleException on 3-node cycle A→B→C→A', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
        'C': ['A'],
      };
      expect(() => detectCycle(adj), throwsA(isA<CycleException>()));
    });

    test('CycleException includes cycle path', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
        'C': ['A'],
      };
      try {
        detectCycle(adj);
        fail('should have thrown');
      } on CycleException catch (e) {
        expect(e.path, isNotEmpty);
        // The path should contain the repeated node at start and end.
        expect(e.path.first, equals(e.path.last));
      }
    });

    test('detects hypothetical edge creating a cycle', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      // C → A would close the cycle.
      expect(
        () => detectCycle(adj, extraFrom: 'C', extraTo: 'A'),
        throwsA(isA<CycleException>()),
      );
    });

    test('hypothetical edge that does not create a cycle is fine', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      // A → C is fine (already reachable but no cycle).
      expect(
        () => detectCycle(adj, extraFrom: 'A', extraTo: 'C'),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // topologicalSort
  // ---------------------------------------------------------------------------
  group('topologicalSort', () {
    test('empty graph returns empty list', () {
      expect(topologicalSort({}), isEmpty);
    });

    test('single node with no edges', () {
      final adj = {'A': <String>[]};
      expect(topologicalSort(adj), equals(['A']));
    });

    test('linear chain A→B→C produces [A, B, C]', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      final order = topologicalSort(adj);
      // A must come before B, B before C.
      expect(order.indexOf('A'), lessThan(order.indexOf('B')));
      expect(order.indexOf('B'), lessThan(order.indexOf('C')));
    });

    test('diamond: A→B, A→C, B→D, C→D', () {
      final adj = {
        'A': ['B', 'C'],
        'B': ['D'],
        'C': ['D'],
      };
      final order = topologicalSort(adj);
      expect(order.indexOf('A'), lessThan(order.indexOf('B')));
      expect(order.indexOf('A'), lessThan(order.indexOf('C')));
      expect(order.indexOf('B'), lessThan(order.indexOf('D')));
      expect(order.indexOf('C'), lessThan(order.indexOf('D')));
    });

    test('throws CycleException on cyclic graph', () {
      final adj = {
        'A': ['B'],
        'B': ['A'],
      };
      expect(() => topologicalSort(adj), throwsA(isA<CycleException>()));
    });
  });

  // ---------------------------------------------------------------------------
  // findReadyTasks
  // ---------------------------------------------------------------------------
  group('findReadyTasks', () {
    test('no strong links — all non-completed tasks are ready', () {
      final ready = findReadyTasks({}, {}, {'A', 'B', 'C'});
      expect(ready, containsAll(['A', 'B', 'C']));
    });

    test('completed tasks are not in the result', () {
      final ready = findReadyTasks({}, {'A'}, {'A', 'B', 'C'});
      expect(ready, isNot(contains('A')));
      expect(ready, containsAll(['B', 'C']));
    });

    test('task blocked by uncompleted predecessor is not ready', () {
      final adj = {
        'A': ['B'],
      };
      // A is not completed — B is blocked.
      final ready = findReadyTasks(adj, {}, {'A', 'B'});
      expect(ready, contains('A'));
      expect(ready, isNot(contains('B')));
    });

    test('task becomes ready after predecessor is completed', () {
      final adj = {
        'A': ['B'],
      };
      final ready = findReadyTasks(adj, {'A'}, {'A', 'B'});
      expect(ready, contains('B'));
      expect(ready, isNot(contains('A'))); // A is completed
    });

    test('chain A→B→C: only A is ready when none completed', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      final ready = findReadyTasks(adj, {}, {'A', 'B', 'C'});
      expect(ready, equals(['A']));
    });

    test('chain A→B→C: B ready when A completed', () {
      final adj = {
        'A': ['B'],
        'B': ['C'],
      };
      final ready = findReadyTasks(adj, {'A'}, {'A', 'B', 'C'});
      expect(ready, contains('B'));
      expect(ready, isNot(contains('C')));
    });

    test('two independent tasks both ready', () {
      final adj = {
        'A': ['C'],
        'B': ['C'],
      };
      final ready = findReadyTasks(adj, {}, {'A', 'B', 'C'});
      expect(ready, containsAll(['A', 'B']));
      expect(ready, isNot(contains('C')));
    });
  });
}
