import 'package:flutter/material.dart';

import '../../domain/export/export_task.dart';

import '../controllers/gesture_controller.dart';
import '../painters/canvas_painter.dart';
import '../viewmodels/canvas_viewmodel.dart';
import '../widgets/toolbar.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    required this.viewModel,
    required this.gestureController,
  });

  final CanvasViewModel viewModel;
  final GestureController gestureController;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  late final CanvasViewModel _viewModel = widget.viewModel;
  late final GestureController _gestureController = widget.gestureController;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('正在导出 PNG...'),
          duration: Duration(seconds: 2),
        ),
      );
    try {
      final task = await _viewModel.exportPage();
      if (!mounted) {
        return;
      }
      messenger.hideCurrentSnackBar();
      if (task == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('导出失败：缺少页面或导出器。')),
        );
        return;
      }
      if (task.status == ExportTaskStatus.completed &&
          task.outputPath != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('导出成功，文件位于：${task.outputPath}')),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              task.errorMessage == null
                  ? '导出失败，请重试。'
                  : '导出失败：${task.errorMessage}',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('导出失败：$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas'),
      ),
      body: Column(
        children: [
          CanvasToolbar(
            onUndo: () => _viewModel.undo(),
            onRedo: () => _viewModel.redo(),
            onExport: () {
              _handleExport();
            },
            activeTool: _viewModel.activeTool.type,
            onToolChange: _viewModel.changeTool,
          ),
          Expanded(
            child: Listener(
              onPointerDown: _gestureController.handlePointerEvent,
              onPointerMove: _gestureController.handlePointerEvent,
              onPointerUp: _gestureController.handlePointerEvent,
              child: GestureDetector(
                onScaleStart: _gestureController.handleScaleStart,
                onScaleUpdate: _gestureController.handleScaleUpdate,
                onScaleEnd: _gestureController.handleScaleEnd,
                child: CustomPaint(
                  foregroundPainter: CanvasPainter(
                    completedStrokes: _viewModel.strokes,
                    inProgressStroke: _viewModel.inProgressStroke,
                    zoom: _viewModel.viewport.zoom,
                    offset: Offset(
                      _viewModel.viewport.offsetX,
                      _viewModel.viewport.offsetY,
                    ),
                  ),
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
