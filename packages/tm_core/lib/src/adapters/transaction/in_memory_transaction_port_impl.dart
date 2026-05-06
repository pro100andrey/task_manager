import '../../application/ports/transaction_port.dart';
import '../../domain/result.dart';
import 'in_memory_snapshot_store.dart';

class InMemoryTransactionPortImpl implements TransactionPort {
  InMemoryTransactionPortImpl(this._stores);

  final List<InMemorySnapshotStore> _stores;

  @override
  Future<T> run<T>(Future<T> Function() action) async {
    final snapshots = [for (final store in _stores) store.createSnapshot()];

    try {
      final result = await action();
      if (result is Failure<dynamic, dynamic>) {
        for (var index = 0; index < _stores.length; index++) {
          _stores[index].restoreSnapshot(snapshots[index]);
        }
      }
      return result;
    } catch (_) {
      for (var index = 0; index < _stores.length; index++) {
        _stores[index].restoreSnapshot(snapshots[index]);
      }
      rethrow;
    }
  }
}
