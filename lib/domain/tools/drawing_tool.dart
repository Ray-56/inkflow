import 'package:meta/meta.dart';

enum DrawingToolType {
  pen,
  highlighter,
  eraser,
}

@immutable
class DrawingTool {
  const DrawingTool({
    required this.type,
    required this.color,
    required this.width,
    this.opacity = 1.0,
  });

  final DrawingToolType type;
  final int color;
  final double width;
  final double opacity;

  bool get isEraser => type == DrawingToolType.eraser;

  DrawingTool copyWith({
    DrawingToolType? type,
    int? color,
    double? width,
    double? opacity,
  }) {
    return DrawingTool(
      type: type ?? this.type,
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
    );
  }

  static DrawingTool pen() => const DrawingTool(
        type: DrawingToolType.pen,
        color: 0xFF000000,
        width: 2.0,
      );
  static DrawingTool highlighter() => const DrawingTool(
        type: DrawingToolType.highlighter,
        color: 0x66F7D51D,
        width: 10.0,
        opacity: 0.6,
      );
  static DrawingTool eraser() => const DrawingTool(
        type: DrawingToolType.eraser,
        color: 0xFFFFFFFF,
        width: 12.0,
      );
}
