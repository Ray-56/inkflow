import 'dart:ui' as ui;

import '../../../domain/strokes/stroke.dart';

class StrokeCacheStore {
  final Map<String, ui.Picture> _cache = {};

  ui.Picture? read(String strokeId) => _cache[strokeId];

  void write(Stroke stroke, ui.Picture picture) {
    _cache[stroke.id] = picture;
  }

  void remove(String strokeId) {
    _cache.remove(strokeId);
  }

  void clear() {
    _cache.clear();
  }
}
