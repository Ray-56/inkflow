import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_repository.dart';
import '../../../domain/pages/page.dart';
import '../../../domain/strokes/stroke.dart';
import '../../../domain/strokes/stroke_repository.dart';
import '../../usecases/strokes/undo_redo_usecase.dart';

class PersistNoteUseCase {
  PersistNoteUseCase({
    required NoteRepository noteRepository,
    required StrokeRepository strokeRepository,
    required UndoRedoUseCase undoRedo,
  })  : _noteRepository = noteRepository,
        _strokeRepository = strokeRepository,
        _undoRedo = undoRedo;

  final NoteRepository _noteRepository;
  final StrokeRepository _strokeRepository;
  final UndoRedoUseCase _undoRedo;

  Future<Note?> loadNote(String noteId) {
    return _noteRepository.loadById(noteId);
  }

  Future<void> saveNote(Note note) {
    return _noteRepository.save(note);
  }

  Future<List<Stroke>> loadPage({
    required Note note,
    required Page page,
  }) async {
    final strokes = await _strokeRepository.loadAll(note.id, page.id);
    _undoRedo.hydrate(past: strokes);
    return strokes;
  }

  Future<void> savePage({
    required Note note,
    required Page page,
    required List<Stroke> strokes,
  }) async {
    await _noteRepository.save(note);
    await _strokeRepository.saveAll(note.id, page.id, strokes);
  }
}
