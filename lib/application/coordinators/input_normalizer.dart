import 'package:flutter/gestures.dart';

import '../../domain/input/input_event.dart';

class InputNormalizer {
  InputEvent fromPointerEvent(PointerEvent event) {
    return InputEvent(
      type: _mapType(event),
      deviceKind: _mapDevice(event.kind),
      toolType: _mapTool(event.kind),
      position: InputPoint(
        x: event.localPosition.dx,
        y: event.localPosition.dy,
      ),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(event.timeStamp.inMilliseconds),
      pressure: event.pressure,
      tilt: event.tilt,
      isPrimary: event.buttons == kPrimaryButton,
    );
  }

  InputEventType _mapType(PointerEvent event) {
    if (event is PointerDownEvent) return InputEventType.down;
    if (event is PointerUpEvent) return InputEventType.up;
    if (event is PointerMoveEvent) return InputEventType.move;
    return InputEventType.hover;
  }

  InputDeviceKind _mapDevice(PointerDeviceKind kind) {
    switch (kind) {
      case PointerDeviceKind.stylus:
        return InputDeviceKind.stylus;
      case PointerDeviceKind.mouse:
        return InputDeviceKind.mouse;
      default:
        return InputDeviceKind.finger;
    }
  }

  InputToolType _mapTool(PointerDeviceKind kind) {
    if (kind == PointerDeviceKind.stylus) {
      return InputToolType.pen;
    }
    if (kind == PointerDeviceKind.mouse) {
      return InputToolType.pen;
    }
    return InputToolType.touch;
  }
}
