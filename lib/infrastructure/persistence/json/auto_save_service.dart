import '../../../application/coordinators/autosave_scheduler.dart';
import '../../../application/usecases/notes/persist_note_usecase.dart';
import '../../../domain/notes/note.dart';
import '../../../domain/pages/page.dart';
import '../../../domain/strokes/stroke.dart';

class AutoSaveService {
  AutoSaveService({
    required AutoSaveScheduler scheduler,
    required PersistNoteUseCase persistUseCase,
    required Note Function() noteProvider,
    required Page Function() pageProvider,
    required List<Stroke> Function() strokesProvider,
  })  : _scheduler = scheduler,
        _persistUseCase = persistUseCase,
        _noteProvider = noteProvider,
        _pageProvider = pageProvider,
        _strokesProvider = strokesProvider;

  final AutoSaveScheduler _scheduler;
  final PersistNoteUseCase _persistUseCase;
  final Note Function() _noteProvider;
  final Page Function() _pageProvider;
  final List<Stroke> Function() _strokesProvider;

  void start() {
    _scheduler.start();
  }

  Future<void> triggerSave() async {
    await _persistUseCase.savePage(
      note: _noteProvider(),
      page: _pageProvider(),
      strokes: _strokesProvider(),
    );
  }

  Future<void> dispose() async {
    _scheduler.stop();
  }
}
