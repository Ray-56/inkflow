import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/pages/page.dart';
import '../../domain/strokes/stroke.dart';
import '../../domain/tools/drawing_tool.dart';

class PngExportAdapter {
  ui.Picture buildPicture(Page page, List<Stroke> strokes) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.srcOver);
    canvas.saveLayer(null, ui.Paint());
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    canvas.restore();
    return recorder.endRecording();
  }

  Future<String> savePicture(ui.Picture picture, Page page) async {
    final dir = await getApplicationDocumentsDirectory();
    final image = await picture.toImage(
      page.dimensions.width.toInt(),
      page.dimensions.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final filePath = p.join(
      dir.path,
      'inkflow_${page.id}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    final file = File(filePath);
    await file.writeAsBytes(byteData!.buffer.asUint8List());
    return filePath;
  }

  void _drawStroke(ui.Canvas canvas, Stroke stroke) {
    final points = stroke.points;
    if (points.isEmpty) {
      return;
    }
    final paint = ui.Paint()
      ..color =
          ui.Color(stroke.tool.color).withValues(alpha: stroke.tool.opacity)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = stroke.tool.width
      ..strokeCap = ui.StrokeCap.round
      ..blendMode =
          stroke.tool.isEraser ? ui.BlendMode.clear : ui.BlendMode.srcOver;
    final path = ui.Path();
    path.moveTo(points.first.x, points.first.y);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, paint);
  }
}
