import 'dart:async';

/// Coordinates periodic autosave triggers based on time and stroke counts.
class AutoSaveScheduler {
  AutoSaveScheduler({
    required Duration interval,
    required int strokeThreshold,
    required Future<void> Function() onAutoSave,
  })  : _interval = interval,
        _strokeThreshold = strokeThreshold,
        _onAutoSave = onAutoSave;

  final Duration _interval;
  final int _strokeThreshold;
  final Future<void> Function() _onAutoSave;

  Timer? _timer;
  int _pendingStrokes = 0;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    _scheduleTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> notifyCheckpoint() async {
    _pendingStrokes = 0;
    await _triggerSave();
  }

  void notifyStrokeCommitted() {
    _pendingStrokes++;
    if (_pendingStrokes >= _strokeThreshold) {
      _pendingStrokes = 0;
      _triggerSave();
    }
  }

  void dispose() {
    stop();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer(_interval, () {
      _timer = null;
      _triggerSave();
      if (_isRunning) {
        _scheduleTimer();
      }
    });
  }

  Future<void> _triggerSave() async {
    await _onAutoSave();
  }
}

enum StorageHealthStatus {
  healthy,
  lowSpace,
  writeFailure,
}

/// Observes storage state and emits warnings to presentation layer.
class StorageHealthMonitor {
  StorageHealthMonitor({
    required Duration checkInterval,
    required Future<int> Function() onQueryFreeBytes,
    required void Function(StorageHealthStatus status) onStatusChanged,
    this.minFreeBytes = 20 * 1024 * 1024,
  })  : _checkInterval = checkInterval,
        _onQueryFreeBytes = onQueryFreeBytes,
        _onStatusChanged = onStatusChanged;

  final Duration _checkInterval;
  final Future<int> Function() _onQueryFreeBytes;
  final void Function(StorageHealthStatus status) _onStatusChanged;
  final int minFreeBytes;

  Timer? _timer;
  StorageHealthStatus _currentStatus = StorageHealthStatus.healthy;

  StorageHealthStatus get status => _currentStatus;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) => _evaluate());
    _evaluate();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _evaluate() async {
    try {
      final bytes = await _onQueryFreeBytes();
      final nextStatus = bytes >= minFreeBytes
          ? StorageHealthStatus.healthy
          : StorageHealthStatus.lowSpace;
      _updateStatus(nextStatus);
    } catch (_) {
      _updateStatus(StorageHealthStatus.writeFailure);
    }
  }

  void _updateStatus(StorageHealthStatus next) {
    if (_currentStatus == next) {
      return;
    }
    _currentStatus = next;
    _onStatusChanged(next);
  }
}
