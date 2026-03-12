import '../../../domain/strokes/stroke.dart';
import '../../../infrastructure/persistence/cache/stroke_cache_store.dart';
import 'in_progress_renderer.dart';

class CacheRebuilder {
  CacheRebuilder({
    required StrokeCacheStore cache,
    required InProgressStrokeRenderer renderer,
  })  : _cache = cache,
        _renderer = renderer;

  final StrokeCacheStore _cache;
  final InProgressStrokeRenderer _renderer;

  void rebuild(List<Stroke> strokes) {
    _cache.clear();
    for (final stroke in strokes) {
      final picture = _renderer.render(stroke);
      _cache.write(stroke, picture);
    }
  }
}
