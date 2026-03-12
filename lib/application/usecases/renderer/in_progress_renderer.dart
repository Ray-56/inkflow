import 'dart:ui' as ui;

import '../../../domain/strokes/stroke.dart';

class InProgressStrokeRenderer {
  ui.Picture render(Stroke stroke) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()
      ..color = ui.Color(stroke.tool.color)
          .withValues(alpha: stroke.tool.opacity)
      ..strokeWidth = stroke.tool.width
      ..strokeCap = ui.StrokeCap.round
      ..style = ui.PaintingStyle.stroke;
    final path = ui.Path();
    final points = stroke.points;
    if (points.isEmpty) {
      return recorder.endRecording();
    }
    path.moveTo(points.first.x, points.first.y);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, paint);
    return recorder.endRecording();
  }
}
