import 'dart:async';

/// Placeholder adapter that would connect to native iOS pencil APIs.
class IosPencilBridgeAdapter {
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> get events {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  void dispatchNativeEvent(Map<String, dynamic> payload) {
    _controller?.add(payload);
  }

  Future<void> dispose() async {
    await _controller?.close();
  }
}
