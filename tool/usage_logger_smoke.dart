import 'package:inkflow/infrastructure/telemetry/usage_logger.dart';

void main() {
  const logger = UsageLogger();

  logger.logEvent(
    'quickstart.telemetry.smoke',
    properties: {
      'source': 'quickstart',
      'timestamp': DateTime.now().toIso8601String(),
      'ok': true,
    },
  );
}
