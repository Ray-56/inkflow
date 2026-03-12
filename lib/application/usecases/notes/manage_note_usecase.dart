import 'dart:math';

import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_repository.dart';
import '../../../domain/pages/page.dart';

class ManageNoteUseCase {
  ManageNoteUseCase(this.repository);

  final NoteRepository repository;

  Future<Note> createNote({
    required String title,
    bool withDefaultPage = true,
  }) async {
    final pages = <Page>[];
    if (withDefaultPage) {
      pages.add(Page.createDefault(id: _genId(), title: 'Page 1'));
    }
    final note = Note(
      id: _genId(),
      title: title,
      pages: pages,
    );
    await repository.save(note);
    return note;
  }

  Future<void> deleteNote(String id) {
    return repository.delete(id);
  }

  Future<Note?> renameNote(String id, String title) async {
    final note = await repository.loadById(id);
    if (note == null) {
      return null;
    }
    final renamed = note.rename(title);
    await repository.save(renamed);
    return renamed;
  }

  Future<List<Note>> listNotes() {
    return repository.loadAll();
  }

  String _genId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}
