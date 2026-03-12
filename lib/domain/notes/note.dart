import '../pages/page.dart';

class Note {
  Note({
    required this.id,
    required this.title,
    List<Page>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _pages = List.unmodifiable(pages ?? <Page>[]),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Page> _pages;

  List<Page> get pages => List.unmodifiable(_pages);

  Page? pageById(String pageId) {
    for (final page in _pages) {
      if (page.id == pageId) {
        return page;
      }
    }
    return null;
  }

  Note rename(String nextTitle) {
    return copyWith(title: nextTitle);
  }

  Note addPage(Page page, {int? index}) {
    final copy = [..._pages];
    if (index != null && index >= 0 && index <= copy.length) {
      copy.insert(index, page);
    } else {
      copy.add(page);
    }
    return copyWith(pages: copy);
  }

  Note removePage(String pageId) {
    final copy = _pages.where((page) => page.id != pageId).toList();
    return copyWith(pages: copy);
  }

  Note duplicatePage(String pageId, {required String newPageId}) {
    final page = pageById(pageId);
    if (page == null) {
      return this;
    }
    return addPage(
      page.copyForDuplicate(newPageId),
      index: _pages.indexOf(page) + 1,
    );
  }

  Note reorderPage(String pageId, int newIndex) {
    if (newIndex < 0 || newIndex >= _pages.length) {
      return this;
    }
    final copy = [..._pages];
    final currentIndex = copy.indexWhere((page) => page.id == pageId);
    if (currentIndex == -1) {
      return this;
    }
    final page = copy.removeAt(currentIndex);
    copy.insert(newIndex, page);
    return copyWith(pages: copy);
  }

  Note copyWith({
    String? title,
    List<Page>? pages,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      pages: pages ?? _pages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
