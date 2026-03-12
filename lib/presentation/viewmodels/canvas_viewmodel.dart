import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../../application/coordinators/input_normalizer.dart';
import '../../application/usecases/export/export_page_usecase.dart';
import '../../application/usecases/notes/persist_note_usecase.dart';
import '../../application/usecases/renderer/cache_rebuilder.dart';
import '../../application/usecases/strokes/stroke_record_usecase.dart';
import '../../application/usecases/strokes/undo_redo_usecase.dart';
import '../../application/usecases/tools/change_tool_usecase.dart';
import '../../domain/export/export_task.dart';
import '../../domain/input/input_event.dart';
import '../../domain/notes/note.dart';
import '../../domain/pages/page.dart';
import '../../domain/sessions/canvas_session.dart';
import '../../domain/strokes/stroke.dart';
import '../../domain/tools/drawing_tool.dart';
import '../../domain/viewport/viewport.dart';

class CanvasViewModel extends ChangeNotifier {
  CanvasViewModel({
    required CanvasSession session,
    required StrokeRecordUseCase strokeUseCase,
    required ChangeDrawingToolUseCase toolUseCase,
    required InputNormalizer normalizer,
    required UndoRedoUseCase undoRedo,
    required CacheRebuilder cacheRebuilder,
    required Note note,
    required Page page,
    List<Stroke> initialStrokes = const [],
    ExportPageUseCase? exportUseCase,
    PersistNoteUseCase? persistNoteUseCase,
  })  : _session = session,
        _strokeUseCase = strokeUseCase,
        _toolUseCase = toolUseCase,
        _normalizer = normalizer,
        _undoRedo = undoRedo,
        _cacheRebuilder = cacheRebuilder,
        _exportUseCase = exportUseCase,
        _persistNoteUseCase = persistNoteUseCase,
        _note = note,
        _page = page {
    _strokeUseCase.registerCallback(onStrokeCommitted);
    _completedStrokes.addAll(initialStrokes);
    _undoRedo.hydrate(past: initialStrokes);
    _cacheRebuilder.rebuild(_completedStrokes);
  }

  final CanvasSession _session;
  final StrokeRecordUseCase _strokeUseCase;
  final ChangeDrawingToolUseCase _toolUseCase;
  final InputNormalizer _normalizer;
  final UndoRedoUseCase _undoRedo;
  final CacheRebuilder _cacheRebuilder;
  final ExportPageUseCase? _exportUseCase;
  final PersistNoteUseCase? _persistNoteUseCase;

  Note? _note;
  Page? _page;
  final List<Stroke> _completedStrokes = [];

  List<Stroke> get strokes => List.unmodifiable(_completedStrokes);
  Stroke? get inProgressStroke => _session.inProgressStroke;
  DrawingTool get activeTool => _toolUseCase.activeTool;
  Viewport get viewport => _session.viewport;
  Page? get page => _page;
  Note? get note => _note;

  void updateContext({
    required Note note,
    required Page page,
    List<Stroke> strokes = const [],
  }) {
    _note = note;
    _page = page;
    _completedStrokes
      ..clear()
      ..addAll(strokes);
    _undoRedo.hydrate(past: strokes);
    _cacheRebuilder.rebuild(_completedStrokes);
    notifyListeners();
  }

  Future<void> handlePointerEvent(PointerEvent event) async {
    final input = _normalizer.fromPointerEvent(event);
    switch (input.type) {
      case InputEventType.down:
        _strokeUseCase.beginStroke(input);
        break;
      case InputEventType.move:
        _strokeUseCase.appendPoint(input);
        break;
      case InputEventType.up:
        await _strokeUseCase.endStroke(input);
        break;
      case InputEventType.hover:
        break;
    }
    notifyListeners();
  }

  Future<void> onStrokeCommitted(Stroke stroke) async {
    _completedStrokes.add(stroke);
    _undoRedo.record(stroke);
    _cacheRebuilder.rebuild(_completedStrokes);
    unawaited(_persistState());
    notifyListeners();
  }

  void changeTool(DrawingToolType type) {
    _toolUseCase.setPreset(type);
    notifyListeners();
  }

  void updateViewport(Viewport viewport) {
    _session.updateViewport(viewport);
    notifyListeners();
  }

  void reset() {
    _completedStrokes.clear();
    unawaited(_persistState());
    notifyListeners();
  }

  Future<void> undo() async {
    final stroke = _undoRedo.undo();
    if (stroke != null) {
      _completedStrokes.removeWhere((element) => element.id == stroke.id);
      _cacheRebuilder.rebuild(_completedStrokes);
      unawaited(_persistState());
      notifyListeners();
    }
  }

  Future<void> redo() async {
    final stroke = _undoRedo.redo();
    if (stroke != null) {
      _completedStrokes.add(stroke);
      _cacheRebuilder.rebuild(_completedStrokes);
      unawaited(_persistState());
      notifyListeners();
    }
  }

  Future<ExportTask?> exportPage() async {
    final page = _page;
    final exportUseCase = _exportUseCase;
    if (page == null || exportUseCase == null) {
      return null;
    }
    return exportUseCase.exportPage(page: page, strokes: _completedStrokes);
  }

  Future<void> _persistState() async {
    final note = _note;
    final page = _page;
    final persistNoteUseCase = _persistNoteUseCase;
    if (note == null || page == null || persistNoteUseCase == null) {
      return;
    }
    await persistNoteUseCase.savePage(
      note: note,
      page: page,
      strokes: _completedStrokes,
    );
  }
}
