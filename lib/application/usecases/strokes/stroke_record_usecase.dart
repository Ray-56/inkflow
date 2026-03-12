import 'dart:math';

import '../../../domain/input/input_event.dart';
import '../../../domain/sessions/canvas_session.dart';
import '../../../domain/strokes/stroke.dart';
import '../../../domain/strokes/stroke_point.dart';

typedef StrokeCommittedCallback = Future<void> Function(Stroke stroke);

class StrokeRecordUseCase {
  StrokeRecordUseCase({
    required CanvasSession session,
    required StrokeCommittedCallback onStrokeCommitted,
  })  : _session = session,
        _onStrokeCommitted = onStrokeCommitted;

  final CanvasSession _session;
  StrokeCommittedCallback _onStrokeCommitted;

  void beginStroke(InputEvent event) {
    if (!_isDrawingDevice(event.deviceKind)) return;
    _session.startStroke(_genId(), _toPoint(event));
  }

  void appendPoint(InputEvent event) {
    if (!_isDrawingDevice(event.deviceKind)) return;
    _session.appendPoint(_toPoint(event));
  }

  Future<Stroke?> endStroke(InputEvent event) async {
    if (!_isDrawingDevice(event.deviceKind)) return null;
    _session.appendPoint(_toPoint(event));
    final stroke = _session.completeStroke();
    if (stroke != null && stroke.points.length > 1) {
      await _onStrokeCommitted(stroke);
    }
    return stroke;
  }

  StrokePoint _toPoint(InputEvent event) {
    return StrokePoint(
      x: event.position.x,
      y: event.position.y,
      pressure: event.pressure,
      tilt: event.tilt,
      timestamp: event.timestamp,
    );
  }

  String _genId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
  void registerCallback(StrokeCommittedCallback callback) {
    _onStrokeCommitted = callback;
  }

  bool _isDrawingDevice(InputDeviceKind kind) {
    return kind == InputDeviceKind.stylus ||
        kind == InputDeviceKind.finger ||
        kind == InputDeviceKind.mouse;
  }
}
