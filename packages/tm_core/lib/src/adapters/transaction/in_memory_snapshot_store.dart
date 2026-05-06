abstract interface class InMemorySnapshotStore {
  Object createSnapshot();

  void restoreSnapshot(Object snapshot);
}
