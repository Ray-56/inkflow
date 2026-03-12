import 'package:flutter/gestures.dart';

import '../../domain/tools/drawing_tool.dart';
import '../viewmodels/canvas_viewmodel.dart';

class GestureController {
  GestureController(this._viewModel);

  final CanvasViewModel _viewModel;

  Offset? _lastPanPosition;
  int? _drawingPointerId;
  final Set<int> _activeTouchPointers = <int>{};
  double _scaleBaseZoom = 1.0;

  Future<void> handlePointerEvent(PointerEvent event) async {
    _trackTouchPointers(event);

    if (_shouldRouteToDrawing(event)) {
      await _viewModel.handlePointerEvent(event);
      if (event.kind == PointerDeviceKind.touch &&
          (event is PointerUpEvent || event is PointerCancelEvent)) {
        _drawingPointerId = null;
      }
      return;
    }

    if (event.kind == PointerDeviceKind.touch) {
      _handleTouchPan(event);
    }
  }

  void handleScaleStart(ScaleStartDetails details) {
    _scaleBaseZoom = _viewModel.viewport.zoom;
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) {
      return;
    }
    final vp = _viewModel.viewport;
    final nextZoom = (_scaleBaseZoom * details.scale).clamp(0.5, 4.0);
    _viewModel.updateViewport(
      vp.copyWith(
        zoom: nextZoom,
        offsetX: vp.offsetX - details.focalPointDelta.dx,
        offsetY: vp.offsetY - details.focalPointDelta.dy,
      ),
    );
  }

  void handleScaleEnd(ScaleEndDetails details) {}

  bool _shouldRouteToDrawing(PointerEvent event) {
    if (event.kind == PointerDeviceKind.stylus) {
      return true;
    }
    if (event.kind != PointerDeviceKind.touch) {
      return false;
    }
    if (!_isDrawingToolSelected) {
      return false;
    }
    if (_drawingPointerId == null) {
      if (_activeTouchPointers.length == 1 && event is PointerDownEvent) {
        _drawingPointerId = event.pointer;
        return true;
      }
      return false;
    }
    return _drawingPointerId == event.pointer;
  }

  bool get _isDrawingToolSelected {
    final type = _viewModel.activeTool.type;
    return type == DrawingToolType.pen ||
        type == DrawingToolType.highlighter ||
        type == DrawingToolType.eraser;
  }

  void _handleTouchPan(PointerEvent event) {
    final canPanWithTouch =
        _drawingPointerId == null && _activeTouchPointers.length == 1;
    if (!canPanWithTouch) {
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        _lastPanPosition = null;
      }
      return;
    }
    if (event is PointerDownEvent) {
      _lastPanPosition = event.position;
      return;
    }
    if (event is PointerMoveEvent && _lastPanPosition != null) {
      final delta = event.position - _lastPanPosition!;
      _lastPanPosition = event.position;
      final vp = _viewModel.viewport;
      _viewModel.updateViewport(
        vp.copyWith(
          offsetX: vp.offsetX - delta.dx,
          offsetY: vp.offsetY - delta.dy,
        ),
      );
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _lastPanPosition = null;
    }
  }

  void _trackTouchPointers(PointerEvent event) {
    if (event.kind != PointerDeviceKind.touch) {
      return;
    }
    if (event is PointerDownEvent) {
      _activeTouchPointers.add(event.pointer);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _activeTouchPointers.remove(event.pointer);
    }
  }

}
