import 'dart:developer' as developer;

/// Minimal telemetry hook for MVP，后续可替换为真实日志上报。
class UsageLogger {
  const UsageLogger();

  void logEvent(String name, {Map<String, Object?>? properties}) {
    developer.log(
      'InkFlow::$name',
      name: 'InkFlowTelemetry',
      error: properties,
    );
  }
}
