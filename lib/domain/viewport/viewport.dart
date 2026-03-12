import 'package:meta/meta.dart';

@immutable
class Viewport {
  const Viewport({
    required this.zoom,
    required this.offsetX,
    required this.offsetY,
  });

  final double zoom;
  final double offsetX;
  final double offsetY;

  Viewport copyWith({
    double? zoom,
    double? offsetX,
    double? offsetY,
  }) {
    return Viewport(
      zoom: zoom ?? this.zoom,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  static const Viewport identity = Viewport(zoom: 1.0, offsetX: 0, offsetY: 0);
}
