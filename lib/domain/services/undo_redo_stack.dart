import 'dart:collection';

/// Generic undo/redo stack that can be persisted by serializing the entries.
class UndoRedoStack<T> {
  UndoRedoStack({
    int maxEntries = 100,
  }) : _maxEntries = maxEntries;

  final int _maxEntries;
  final Queue<T> _past = Queue<T>();
  final Queue<T> _future = Queue<T>();

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  /// Entries already applied, ordered oldest → newest.
  List<T> get pastEntries => List.unmodifiable(_past);

  /// Entries that can be re-applied, ordered oldest → newest.
  List<T> get futureEntries => List.unmodifiable(_future);

  void record(T entry) {
    _past.addLast(entry);
    _enforceMaxEntries();
    _future.clear();
  }

  T? undo() {
    if (!canUndo) {
      return null;
    }
    final value = _past.removeLast();
    _future.addFirst(value);
    return value;
  }

  T? redo() {
    if (!canRedo) {
      return null;
    }
    final value = _future.removeFirst();
    _past.addLast(value);
    _enforceMaxEntries();
    return value;
  }

  void clear() {
    _past.clear();
    _future.clear();
  }

  /// Restores persisted history (oldest → newest for both past & future).
  void hydrate({
    Iterable<T> past = const [],
    Iterable<T> future = const [],
  }) {
    _past
      ..clear()
      ..addAll(past);
    _future
      ..clear()
      ..addAll(future);
    _enforceMaxEntries();
  }

  void _enforceMaxEntries() {
    while (_past.length > _maxEntries) {
      _past.removeFirst();
    }
    while (_future.length > _maxEntries) {
      _future.removeLast();
    }
  }
}
