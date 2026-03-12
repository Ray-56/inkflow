import '../../../domain/export/export_task.dart';
import '../../../domain/pages/page.dart';
import '../../../domain/strokes/stroke.dart';
import '../../../infrastructure/adapters/png_export_adapter.dart';

typedef ExportProgressCallback = void Function(ExportTask task);

class ExportPageUseCase {
  ExportPageUseCase({
    required PngExportAdapter adapter,
    required ExportProgressCallback onUpdate,
  })  : _adapter = adapter,
        _onUpdate = onUpdate;

  final PngExportAdapter _adapter;
  final ExportProgressCallback _onUpdate;

  Future<ExportTask> exportPage({
    required Page page,
    required List<Stroke> strokes,
  }) async {
    var task = ExportTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      pageId: page.id,
      requestedAt: DateTime.now(),
    );
    _onUpdate(task);
    try {
      final picture = _adapter.buildPicture(page, strokes);
      final path = await _adapter.savePicture(picture, page);
      task = task.copyWith(
        status: ExportTaskStatus.completed,
        completedAt: DateTime.now(),
        outputPath: path,
      );
      _onUpdate(task);
      return task;
    } catch (error) {
      task = task.copyWith(
        status: ExportTaskStatus.failed,
        completedAt: DateTime.now(),
        errorMessage: error.toString(),
      );
      _onUpdate(task);
      rethrow;
    }
  }
}
