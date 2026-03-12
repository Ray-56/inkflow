import '../../../domain/sessions/canvas_session.dart';
import '../../../domain/tools/drawing_tool.dart';

class ChangeDrawingToolUseCase {
  ChangeDrawingToolUseCase(this._session);

  final CanvasSession _session;

  void setTool(DrawingTool tool) {
    _session.setTool(tool);
  }

  DrawingTool get activeTool => _session.activeTool;

  void setPreset(DrawingToolType type) {
    if (type == DrawingToolType.pen) {
      setTool(DrawingTool.pen());
    } else if (type == DrawingToolType.highlighter) {
      setTool(DrawingTool.highlighter());
    } else {
      setTool(DrawingTool.eraser());
    }
  }
}
