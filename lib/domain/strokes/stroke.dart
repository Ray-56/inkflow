import 'package:meta/meta.dart';

import '../tools/drawing_tool.dart';
import 'stroke_point.dart';

@immutable
class Stroke {
  Stroke({
    required this.id,
    required this.pageId,
    required this.tool,
    required List<StrokePoint> points,
    DateTime? startedAt,
    DateTime? completedAt,
  })  : points = List.unmodifiable(points),
        startedAt = startedAt ?? DateTime.now(),
        completedAt = completedAt ?? DateTime.now();

  final String id;
  final String pageId;
  final DrawingTool tool;
  final List<StrokePoint> points;
  final DateTime startedAt;
  final DateTime completedAt;

  RectBounds get bounds {
    if (points.isEmpty) {
      return const RectBounds(0, 0, 0, 0);
    }
    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;
    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }
    return RectBounds(minX, minY, maxX, maxY);
  }

  Stroke copyWith({
    List<StrokePoint>? points,
    DrawingTool? tool,
    DateTime? completedAt,
  }) {
    return Stroke(
      id: id,
      pageId: pageId,
      tool: tool ?? this.tool,
      points: points ?? this.points,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@immutable
class RectBounds {
  const RectBounds(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
}
