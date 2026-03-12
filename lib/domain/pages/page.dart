/// Available background templates MVP supports.
enum PageBackgroundStyle {
  blank,
  ruled,
  dotted,
  grid,
}

/// Simple immutable page size descriptor (points).
class PageDimensions {
  const PageDimensions({
    required this.width,
    required this.height,
  })  : assert(width > 0),
        assert(height > 0);

  final double width;
  final double height;

  PageDimensions copyWith({
    double? width,
    double? height,
  }) {
    return PageDimensions(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// Domain aggregate representing a single canvas page.
class Page {
  Page({
    required this.id,
    required this.title,
    required this.background,
    required this.dimensions,
    required this.createdAt,
    DateTime? updatedAt,
    List<String>? strokeIds,
  })  : updatedAt = updatedAt ?? DateTime.now(),
        _strokeIds = List.unmodifiable(strokeIds ?? <String>[]);

  final String id;
  final String title;
  final PageBackgroundStyle background;
  final PageDimensions dimensions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> _strokeIds;

  List<String> get strokeIds => List.unmodifiable(_strokeIds);

  Page copyWith({
    String? title,
    PageBackgroundStyle? background,
    PageDimensions? dimensions,
    List<String>? strokeIds,
  }) {
    return Page(
      id: id,
      title: title ?? this.title,
      background: background ?? this.background,
      dimensions: dimensions ?? this.dimensions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      strokeIds: strokeIds ?? _strokeIds,
    );
  }

  Page addStroke(String strokeId) {
    return copyWith(strokeIds: [..._strokeIds, strokeId]);
  }

  Page removeStroke(String strokeId) {
    return copyWith(
      strokeIds: _strokeIds.where((id) => id != strokeId).toList(),
    );
  }

  static Page createDefault({
    required String id,
    required String title,
  }) {
    return Page(
      id: id,
      title: title,
      background: PageBackgroundStyle.blank,
      dimensions:
          const PageDimensions(width: 1190, height: 1684), // A4 @ 140 dpi
      createdAt: DateTime.now(),
    );
  }

  Page copyForDuplicate(String newId) {
    return Page(
      id: newId,
      title: '$title (Copy)',
      background: background,
      dimensions: dimensions,
      createdAt: DateTime.now(),
      strokeIds: _strokeIds,
    );
  }
}
