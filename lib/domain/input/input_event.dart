import 'package:meta/meta.dart';

/// Distinguishes the physical device that generated the input stream.
enum InputDeviceKind {
  stylus,
  finger,
  mouse,
}

/// Represents the intent of the event within a stroke lifecycle.
enum InputEventType {
  down,
  move,
  up,
  hover,
}

/// Optional tool metadata when the platform can differentiate pen types.
enum InputToolType {
  pen,
  highlighter,
  eraser,
  touch,
  unknown,
}

/// Simple immutable coordinate independent of Flutter UI types.
@immutable
class InputPoint {
  const InputPoint({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;
}

/// Domain-friendly input event consumed by Application/Domain layers.
@immutable
class InputEvent {
  const InputEvent({
    required this.type,
    required this.deviceKind,
    required this.position,
    required this.timestamp,
    this.pressure = 0.0,
    this.tilt = 0.0,
    this.toolType = InputToolType.unknown,
    this.isPrimary = true,
  });

  final InputEventType type;
  final InputDeviceKind deviceKind;
  final InputPoint position;
  final DateTime timestamp;
  final double pressure; // Normalized 0.0-1.0 when available.
  final double tilt; // Radians relative to screen normal (0-PI/2).
  final InputToolType toolType;
  final bool isPrimary;

  InputEvent copyWith({
    InputEventType? type,
    InputDeviceKind? deviceKind,
    InputPoint? position,
    DateTime? timestamp,
    double? pressure,
    double? tilt,
    InputToolType? toolType,
    bool? isPrimary,
  }) {
    return InputEvent(
      type: type ?? this.type,
      deviceKind: deviceKind ?? this.deviceKind,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      pressure: pressure ?? this.pressure,
      tilt: tilt ?? this.tilt,
      toolType: toolType ?? this.toolType,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
