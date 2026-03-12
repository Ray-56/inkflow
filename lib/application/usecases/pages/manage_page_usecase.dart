import 'dart:math';

import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_repository.dart';
import '../../../domain/pages/page.dart';

class ManagePageUseCase {
  ManagePageUseCase(this._repository);

  final NoteRepository _repository;

  Future<Note?> addPage(
    String noteId, {
    String? pageTitle,
    int? insertIndex,
  }) async {
    final note = await _repository.loadById(noteId);
    if (note == null) {
      return null;
    }
    final added = note.addPage(
      Page.createDefault(
        id: _genId(),
        title: pageTitle ?? 'Page ${note.pages.length + 1}',
      ),
      index: insertIndex,
    );
    await _repository.save(added);
    return added;
  }

  Future<Note?> deletePage(String noteId, String pageId) async {
    final note = await _repository.loadById(noteId);
    if (note == null) {
      return null;
    }
    final updated = note.removePage(pageId);
    await _repository.save(updated);
    return updated;
  }

  Future<Note?> duplicatePage(String noteId, String pageId) async {
    final note = await _repository.loadById(noteId);
    if (note == null) {
      return null;
    }
    final updated = note.duplicatePage(pageId, newPageId: _genId());
    await _repository.save(updated);
    return updated;
  }

  Future<Note?> reorderPage(String noteId, String pageId, int newIndex) async {
    final note = await _repository.loadById(noteId);
    if (note == null) {
      return null;
    }
    final updated = note.reorderPage(pageId, newIndex);
    await _repository.save(updated);
    return updated;
  }

  String _genId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}
