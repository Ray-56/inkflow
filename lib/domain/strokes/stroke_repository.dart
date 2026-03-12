import 'stroke.dart';

abstract class StrokeRepository {
  Future<void> saveAll(String noteId, String pageId, List<Stroke> strokes);
  Future<List<Stroke>> loadAll(String noteId, String pageId);
}
