import 'note.dart';

/// Repository abstraction for loading and persisting note aggregates.
abstract class NoteRepository {
  Future<List<Note>> loadAll();

  Future<Note?> loadById(String id);

  Future<void> save(Note note);

  Future<void> delete(String id);
}
