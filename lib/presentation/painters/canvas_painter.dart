import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/strokes/stroke.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({
    required this.completedStrokes,
    required this.inProgressStroke,
    required this.zoom,
    required this.offset,
  });

  final List<Stroke> completedStrokes;
  final Stroke? inProgressStroke;
  final double zoom;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(zoom);
    // Use an offscreen layer so BlendMode.clear erases only existing strokes
    // instead of also clearing the white background beneath the canvas.
    canvas.saveLayer(null, Paint());
    for (final stroke in completedStrokes) {
      _drawStroke(canvas, stroke);
    }
    if (inProgressStroke != null) {
      _drawStroke(canvas, inProgressStroke!);
    }
    canvas.restore();
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color =
          Color(stroke.tool.color).withValues(alpha: stroke.tool.opacity)
      ..style =
          stroke.tool.isEraser ? PaintingStyle.stroke : PaintingStyle.stroke
      ..strokeWidth = stroke.tool.width
      ..strokeCap = StrokeCap.round
      ..blendMode =
          stroke.tool.isEraser ? ui.BlendMode.clear : ui.BlendMode.srcOver;

    final path = Path();
    final points = stroke.points;
    if (points.isEmpty) {
      return;
    }
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.completedStrokes != completedStrokes ||
        oldDelegate.inProgressStroke != inProgressStroke ||
        oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset;
  }
}
