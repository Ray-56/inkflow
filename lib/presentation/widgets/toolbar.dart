import 'package:flutter/material.dart';

import '../../domain/tools/drawing_tool.dart';

class CanvasToolbar extends StatelessWidget {
  const CanvasToolbar({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onExport,
    required this.activeTool,
    required this.onToolChange,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onExport;
  final DrawingToolType activeTool;
  final void Function(DrawingToolType type) onToolChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onUndo, icon: const Icon(Icons.undo)),
          IconButton(onPressed: onRedo, icon: const Icon(Icons.redo)),
          const SizedBox(width: 16),
          ChoiceChip(
            label: const Text('Pen'),
            selected: activeTool == DrawingToolType.pen,
            onSelected: (_) => onToolChange(DrawingToolType.pen),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Highlighter'),
            selected: activeTool == DrawingToolType.highlighter,
            onSelected: (_) => onToolChange(DrawingToolType.highlighter),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Eraser'),
            selected: activeTool == DrawingToolType.eraser,
            onSelected: (_) => onToolChange(DrawingToolType.eraser),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PNG'),
          ),
        ],
      ),
    );
  }
}
