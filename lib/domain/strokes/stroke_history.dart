import 'stroke.dart';

class StrokeHistory {
  StrokeHistory({
    List<Stroke>? applied,
    List<Stroke>? undone,
  })  : _applied = List.unmodifiable(applied ?? []),
        _undone = List.unmodifiable(undone ?? []);

  final List<Stroke> _applied;
  final List<Stroke> _undone;

  List<Stroke> get applied => List.unmodifiable(_applied);
  List<Stroke> get undone => List.unmodifiable(_undone);

  StrokeHistory record(Stroke stroke) {
    return StrokeHistory(
      applied: [..._applied, stroke],
      undone: const [],
    );
  }

  StrokeHistory undo() {
    if (_applied.isEmpty) {
      return this;
    }
    final copy = [..._applied];
    final tail = copy.removeLast();
    return StrokeHistory(
      applied: copy,
      undone: [tail, ..._undone],
    );
  }

  StrokeHistory redo() {
    if (_undone.isEmpty) {
      return this;
    }
    final copy = [..._applied, _undone.first];
    final future = [..._undone]..removeAt(0);
    return StrokeHistory(
      applied: copy,
      undone: future,
    );
  }
}
