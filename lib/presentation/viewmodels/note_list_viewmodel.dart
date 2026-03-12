import 'package:flutter/foundation.dart';

import '../../application/usecases/notes/manage_note_usecase.dart';
import '../../application/usecases/pages/manage_page_usecase.dart';
import '../../domain/notes/note.dart';

class NoteListViewModel extends ChangeNotifier {
  NoteListViewModel({
    required ManageNoteUseCase noteUseCase,
    required ManagePageUseCase pageUseCase,
  })  : _noteUseCase = noteUseCase,
        _pageUseCase = pageUseCase;

  final ManageNoteUseCase _noteUseCase;
  final ManagePageUseCase _pageUseCase;

  List<Note> _notes = const [];
  bool _isLoading = false;
  Note? _selectedNote;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  Note? get selectedNote => _selectedNote;

  Future<void> loadNotes() async {
    _setLoading(true);
    _notes = await _noteUseCase.listNotes();
    _selectedNote = _notes.isEmpty ? null : _notes.first;
    _setLoading(false);
  }

  Future<void> createNote(String title) async {
    final note = await _noteUseCase.createNote(title: title);
    _notes = [..._notes, note];
    _selectedNote = note;
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _noteUseCase.deleteNote(noteId);
    _notes = _notes.where((note) => note.id != noteId).toList();
    if (_selectedNote?.id == noteId) {
      _selectedNote = _notes.isEmpty ? null : _notes.first;
    }
    notifyListeners();
  }

  Future<void> renameNote(String noteId, String title) async {
    final updated = await _noteUseCase.renameNote(noteId, title);
    if (updated == null) {
      return;
    }
    _notes = _notes.map((note) => note.id == noteId ? updated : note).toList();
    if (_selectedNote?.id == noteId) {
      _selectedNote = updated;
    }
    notifyListeners();
  }

  Future<void> addPage(String noteId) async {
    final updated = await _pageUseCase.addPage(noteId);
    if (updated == null) {
      return;
    }
    _replaceNote(updated);
  }

  Future<void> removePage(String noteId, String pageId) async {
    final updated = await _pageUseCase.deletePage(noteId, pageId);
    if (updated == null) {
      return;
    }
    _replaceNote(updated);
  }

  Future<void> duplicatePage(String noteId, String pageId) async {
    final updated = await _pageUseCase.duplicatePage(noteId, pageId);
    if (updated == null) {
      return;
    }
    _replaceNote(updated);
  }

  Future<void> reorderPage(String noteId, String pageId, int newIndex) async {
    final updated = await _pageUseCase.reorderPage(noteId, pageId, newIndex);
    if (updated == null) {
      return;
    }
    _replaceNote(updated);
  }

  void selectNote(String noteId) {
    if (_notes.isEmpty) {
      return;
    }
    _selectedNote = _notes.firstWhere(
      (note) => note.id == noteId,
      orElse: () => _selectedNote ?? _notes.first,
    );
    notifyListeners();
  }

  void _replaceNote(Note note) {
    _notes = _notes
        .map((existing) => existing.id == note.id ? note : existing)
        .toList();
    if (_selectedNote?.id == note.id) {
      _selectedNote = note;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
