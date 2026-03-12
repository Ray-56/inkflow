import '../../domain/notes/note.dart';
import '../../domain/notes/note_repository.dart';
import '../persistence/json/note_store.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._store);

  final NoteStore _store;

  @override
  Future<void> delete(String id) async {
    final notes = await loadAll();
    final next = notes.where((note) => note.id != id).toList();
    await _store.saveAll(next);
  }

  @override
  Future<List<Note>> loadAll() {
    return _store.loadAll();
  }

  @override
  Future<Note?> loadById(String id) async {
    final notes = await loadAll();
    for (final note in notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  @override
  Future<void> save(Note note) async {
    final notes = await loadAll();
    bool inserted = false;
    final updated = notes.map((existing) {
      if (existing.id == note.id) {
        inserted = true;
        return note;
      }
      return existing;
    }).toList();
    if (!inserted) {
      updated.add(note);
    }
    await _store.saveAll(updated);
  }
}
