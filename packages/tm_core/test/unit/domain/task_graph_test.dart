import 'package:test/test.dart';
import 'package:tm_core/tm_core.dart';

final a = TaskId.generate();
final b = TaskId.generate();
final c = TaskId.generate();
final d = TaskId.generate();

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
        a: [b],
        b: [c],
      };
      expect(() => detectCycle(adj), returnsNormally);
    });

    test('no exception on parallel paths A→C and B→C', () {
      final adj = {
        a: [c],
        b: [c],
      };
      expect(() => detectCycle(adj), returnsNormally);
    });

    test('throws CycleException on direct cycle A→B→A', () {
      final adj = {
        a: [b],
        b: [a],
      };
      expect(() => detectCycle(adj), throwsA(isA<CycleException>()));
    });

    test('throws CycleException on 3-node cycle A→B→C→A', () {
      final adj = {
        a: [b],
        b: [c],
        c: [a],
      };
      expect(() => detectCycle(adj), throwsA(isA<CycleException>()));
    });

    test('CycleException includes cycle path', () {
      final adj = {
        a: [b],
        b: [c],
        c: [a],
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
        a: [b],
        b: [c],
      };
      // C → A would close the cycle.
      expect(
        () => detectCycle(adj, extraFrom: c, extraTo: a),
        throwsA(isA<CycleException>()),
      );
    });

    test('hypothetical edge that does not create a cycle is fine', () {
      final adj = {
        a: [b],
        b: [c],
      };
      // A → C is fine (already reachable but no cycle).
      expect(
        () => detectCycle(
          adj,
          extraFrom: a,
          extraTo: c,
        ),
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
      final a = TaskId.generate();
      final adj = {a: <TaskId>[]};
      expect(topologicalSort(adj), equals([a]));
    });

    test('linear chain A→B→C produces [A, B, C]', () {
      final adj = {
        a: [b],
        b: [c],
      };
      final order = topologicalSort(adj);
      // A must come before B, B before C.
      expect(order.indexOf(a), lessThan(order.indexOf(b)));
      expect(order.indexOf(b), lessThan(order.indexOf(c)));
    });

    test('diamond: A→B, A→C, B→D, C→D', () {
      final adj = {
        a: [b, c],
        b: [d],
        c: [d],
      };
      final order = topologicalSort(adj);
      expect(order.indexOf(a), lessThan(order.indexOf(b)));
      expect(order.indexOf(a), lessThan(order.indexOf(c)));
      expect(order.indexOf(b), lessThan(order.indexOf(d)));
      expect(order.indexOf(c), lessThan(order.indexOf(d)));
    });

    test('throws CycleException on cyclic graph', () {
      final adj = {
        a: [b],
        b: [a],
      };
      expect(() => topologicalSort(adj), throwsA(isA<CycleException>()));
    });
  });

  // ---------------------------------------------------------------------------
  // findReadyTasks
  // ---------------------------------------------------------------------------
  group('findReadyTasks', () {
    test('no strong links — all non-completed tasks are ready', () {
      final ready = findReadyTasks({}, {}, {a, b, c});
      expect(ready, containsAll([a, b, c]));
    });

    test('completed tasks are not in the result', () {
      final ready = findReadyTasks({}, {a}, {a, b, c});
      expect(ready, isNot(contains(a)));
      expect(ready, containsAll([b, c]));
    });

    test('task blocked by uncompleted predecessor is not ready', () {
      final adj = {
        a: [b],
      };
      // A is not completed — B is blocked.
      final ready = findReadyTasks(adj, {}, {a, b});
      expect(ready, contains(a));
      expect(ready, isNot(contains(b)));
    });

    test('task becomes ready after predecessor is completed', () {
      final adj = {
        a: [b],
      };
      final ready = findReadyTasks(adj, {a}, {a, b});
      expect(ready, contains(b));
      expect(ready, isNot(contains(a))); // A is completed
    });

    test('chain A→B→C: only A is ready when none completed', () {
      final adj = {
        a: [b],
        b: [c],
      };
      final ready = findReadyTasks(adj, {}, {a, b, c});
      expect(ready, equals([a]));
    });

    test('chain A→B→C: B ready when A completed', () {
      final adj = {
        a: [b],
        b: [c],
      };
      final ready = findReadyTasks(adj, {a}, {a, b, c});
      expect(ready, contains(b));
      expect(ready, isNot(contains(c)));
    });

    test('two independent tasks both ready', () {
      final adj = {
        a: [c],
        b: [c],
      };
      final ready = findReadyTasks(adj, {}, {a, b, c});
      expect(ready, containsAll([a, b]));
      expect(ready, isNot(contains(c)));
    });
  });
}
