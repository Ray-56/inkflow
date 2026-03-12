import '../../../domain/services/undo_redo_stack.dart';
import '../../../domain/strokes/stroke.dart';
import '../../../domain/strokes/stroke_history.dart';

class UndoRedoUseCase {
  UndoRedoUseCase(this._stack);

  final UndoRedoStack<Stroke> _stack;

  StrokeHistory history = StrokeHistory();

  Stroke? undo() {
    final stroke = _stack.undo();
    if (stroke != null) {
      history = history.undo();
    }
    return stroke;
  }

  Stroke? redo() {
    final stroke = _stack.redo();
    if (stroke != null) {
      history = history.redo();
    }
    return stroke;
  }

  void record(Stroke stroke) {
    _stack.record(stroke);
    history = history.record(stroke);
  }

  void hydrate({
    Iterable<Stroke> past = const [],
    Iterable<Stroke> future = const [],
  }) {
    _stack.hydrate(past: past, future: future);
    history = StrokeHistory(applied: past.toList(), undone: future.toList());
  }
}
