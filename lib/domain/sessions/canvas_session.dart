import '../strokes/stroke.dart';
import '../strokes/stroke_point.dart';
import '../tools/drawing_tool.dart';
import '../viewport/viewport.dart';

class CanvasSession {
  CanvasSession({
    required this.noteId,
    required this.pageId,
    DrawingTool? initialTool,
    Viewport? viewport,
  })  : activeTool = initialTool ?? DrawingTool.pen(),
        viewport = viewport ?? Viewport.identity;

  final String noteId;
  final String pageId;
  DrawingTool activeTool;
  Viewport viewport;

  Stroke? _inProgressStroke;

  Stroke? get inProgressStroke => _inProgressStroke;

  void updateViewport(Viewport next) {
    viewport = next;
  }

  void setTool(DrawingTool tool) {
    activeTool = tool;
  }

  void startStroke(String strokeId, StrokePoint startPoint) {
    _inProgressStroke = Stroke(
      id: strokeId,
      pageId: pageId,
      tool: activeTool,
      points: [startPoint],
      startedAt: startPoint.timestamp,
    );
  }

  void appendPoint(StrokePoint point) {
    final stroke = _inProgressStroke;
    if (stroke == null) {
      return;
    }
    final nextPoints = [...stroke.points, point];
    _inProgressStroke = stroke.copyWith(points: nextPoints);
  }

  Stroke? completeStroke() {
    final stroke = _inProgressStroke;
    _inProgressStroke = null;
    return stroke;
  }
}
