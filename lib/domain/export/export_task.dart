enum ExportTaskStatus {
  pending,
  running,
  completed,
  failed,
}

class ExportTask {
  ExportTask({
    required this.id,
    required this.pageId,
    required this.requestedAt,
    this.completedAt,
    this.status = ExportTaskStatus.pending,
    this.outputPath,
    this.errorMessage,
  });

  final String id;
  final String pageId;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final ExportTaskStatus status;
  final String? outputPath;
  final String? errorMessage;

  ExportTask copyWith({
    ExportTaskStatus? status,
    DateTime? completedAt,
    String? outputPath,
    String? errorMessage,
  }) {
    return ExportTask(
      id: id,
      pageId: pageId,
      requestedAt: requestedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
