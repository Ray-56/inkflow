import 'package:flutter/material.dart' hide Page;
import 'package:path_provider/path_provider.dart';

import 'application/coordinators/input_normalizer.dart';
import 'application/usecases/export/export_page_usecase.dart';
import 'application/usecases/notes/manage_note_usecase.dart';
import 'application/usecases/notes/persist_note_usecase.dart';
import 'application/usecases/pages/manage_page_usecase.dart';
import 'application/usecases/renderer/cache_rebuilder.dart';
import 'application/usecases/renderer/in_progress_renderer.dart';
import 'application/usecases/strokes/stroke_record_usecase.dart';
import 'application/usecases/strokes/undo_redo_usecase.dart';
import 'application/usecases/tools/change_tool_usecase.dart';
import 'domain/notes/note.dart';
import 'domain/pages/page.dart';
import 'domain/services/undo_redo_stack.dart';
import 'domain/sessions/canvas_session.dart';
import 'domain/strokes/stroke.dart';
import 'domain/strokes/stroke_repository.dart';
import 'infrastructure/adapters/png_export_adapter.dart';
import 'infrastructure/persistence/cache/stroke_cache_store.dart';
import 'infrastructure/persistence/json/note_store.dart';
import 'infrastructure/repositories/note_repository_impl.dart';
import 'infrastructure/repositories/stroke_repository_impl.dart';
import 'infrastructure/security/file_storage_security_service.dart';
import 'presentation/controllers/gesture_controller.dart';
import 'presentation/pages/canvas_page.dart';
import 'presentation/pages/note_list_page.dart';
import 'presentation/viewmodels/canvas_viewmodel.dart';
import 'presentation/viewmodels/note_list_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final securityService = FileStorageSecurityService(
    directoryResolver: getApplicationDocumentsDirectory,
  );
  await securityService.ensureInitialized();

  final noteStore = NoteStore(
    directoryResolver: getApplicationDocumentsDirectory,
    securityService: securityService,
  );
  final noteRepository = NoteRepositoryImpl(noteStore);
  final strokeRepository = StrokeRepositoryImpl(
    directoryResolver: getApplicationDocumentsDirectory,
    securityService: securityService,
  );
  final manageNote = ManageNoteUseCase(noteRepository);
  final managePage = ManagePageUseCase(noteRepository);
  runApp(
    InkFlowApp(
      dependencies: AppDependencies(
        manageNoteUseCase: manageNote,
        managePageUseCase: managePage,
        noteRepository: noteRepository,
        strokeRepository: strokeRepository,
        pngExportAdapter: PngExportAdapter(),
      ),
    ),
  );
}

class AppDependencies {
  AppDependencies({
    required this.manageNoteUseCase,
    required this.managePageUseCase,
    required this.noteRepository,
    required this.strokeRepository,
    required this.pngExportAdapter,
  });

  final ManageNoteUseCase manageNoteUseCase;
  final ManagePageUseCase managePageUseCase;
  final NoteRepositoryImpl noteRepository;
  final StrokeRepository strokeRepository;
  final PngExportAdapter pngExportAdapter;
}

class InkFlowApp extends StatelessWidget {
  const InkFlowApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkFlow',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: InkFlowHome(dependencies: dependencies),
    );
  }
}

class InkFlowHome extends StatefulWidget {
  const InkFlowHome({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<InkFlowHome> createState() => _InkFlowHomeState();
}

class _InkFlowHomeState extends State<InkFlowHome> {
  late final NoteListViewModel _viewModel = NoteListViewModel(
    noteUseCase: widget.dependencies.manageNoteUseCase,
    pageUseCase: widget.dependencies.managePageUseCase,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NoteListPage(
      viewModel: _viewModel,
      onOpenPage: _openCanvas,
    );
  }

  Future<void> _openCanvas(Note note, Page page) async {
    final strokes = await _loadStrokes(note, page);
    final session = CanvasSession(noteId: note.id, pageId: page.id);
    final strokeUseCase = StrokeRecordUseCase(
      session: session,
      onStrokeCommitted: (_) async {},
    );
    final toolUseCase = ChangeDrawingToolUseCase(session);
    final normalizer = InputNormalizer();
    final undoRedo = UndoRedoUseCase(UndoRedoStack<Stroke>(maxEntries: 200));
    final cacheRebuilder = CacheRebuilder(
      cache: StrokeCacheStore(),
      renderer: InProgressStrokeRenderer(),
    );
    final exportUseCase = ExportPageUseCase(
      adapter: widget.dependencies.pngExportAdapter,
      onUpdate: (task) =>
          debugPrint('Export ${task.status} -> ${task.outputPath ?? ''}'),
    );
    final persistUseCase = PersistNoteUseCase(
      noteRepository: widget.dependencies.noteRepository,
      strokeRepository: widget.dependencies.strokeRepository,
      undoRedo: undoRedo,
    );
    final viewModel = CanvasViewModel(
      session: session,
      strokeUseCase: strokeUseCase,
      toolUseCase: toolUseCase,
      normalizer: normalizer,
      undoRedo: undoRedo,
      cacheRebuilder: cacheRebuilder,
      note: note,
      page: page,
      initialStrokes: strokes,
      exportUseCase: exportUseCase,
      persistNoteUseCase: persistUseCase,
    );
    final gestureController = GestureController(viewModel);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CanvasPage(
          viewModel: viewModel,
          gestureController: gestureController,
        ),
      ),
    );
  }

  Future<List<Stroke>> _loadStrokes(Note note, Page page) async {
    final persist = PersistNoteUseCase(
      noteRepository: widget.dependencies.noteRepository,
      strokeRepository: widget.dependencies.strokeRepository,
      undoRedo: UndoRedoUseCase(UndoRedoStack<Stroke>()),
    );
    return persist.loadPage(note: note, page: page);
  }
}
