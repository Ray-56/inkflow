import 'package:meta/meta.dart';

@immutable
class StrokePoint {
  const StrokePoint({
    required this.x,
    required this.y,
    required this.timestamp,
    this.pressure = 0.0,
    this.tilt = 0.0,
  });

  final double x;
  final double y;
  final DateTime timestamp;
  final double pressure;
  final double tilt;

  StrokePoint copyWith({
    double? x,
    double? y,
    DateTime? timestamp,
    double? pressure,
    double? tilt,
  }) {
    return StrokePoint(
      x: x ?? this.x,
      y: y ?? this.y,
      timestamp: timestamp ?? this.timestamp,
      pressure: pressure ?? this.pressure,
      tilt: tilt ?? this.tilt,
    );
  }
}
