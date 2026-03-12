import 'package:flutter/material.dart' hide Page;

import '../../domain/notes/note.dart';
import '../../domain/pages/page.dart';
import '../viewmodels/note_list_viewmodel.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({
    super.key,
    required this.viewModel,
    this.onOpenPage,
  });

  final NoteListViewModel viewModel;
  final void Function(Note note, Page page)? onOpenPage;

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late final NoteListViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleChange);
    _viewModel.loadNotes();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _viewModel.selectedNote;
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkFlow Notes'),
        actions: [
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.note_add),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildNotesList(),
          ),
          if (selected != null)
            Expanded(
              flex: 3,
              child: _buildPagesList(selected),
            )
          else
            const Expanded(
              flex: 3,
              child: Center(child: Text('Select a note')),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: _viewModel.notes
          .map(
            (note) => ListTile(
              title: Text(note.title),
              selected: _viewModel.selectedNote?.id == note.id,
              onTap: () => _viewModel.selectNote(note.id),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _viewModel.deleteNote(note.id);
                  } else if (value == 'rename') {
                    _showRenameDialog(context, note.id, note.title);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagesList(Note note) {
    return Column(
      children: [
        ListTile(
          title: const Text('Pages'),
          trailing: IconButton(
            onPressed: () => _viewModel.addPage(note.id),
            icon: const Icon(Icons.add),
          ),
        ),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final pageId = note.pages[oldIndex].id;
              _viewModel.reorderPage(note.id, pageId, newIndex);
            },
            children: [
              for (final page in note.pages)
                ListTile(
                  key: ValueKey(page.id),
                  title: Text(page.title),
                  subtitle: Text(page.background.name),
                  onTap: () => widget.onOpenPage?.call(note, page),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'duplicate') {
                        _viewModel.duplicatePage(note.id, page.id);
                      } else if (value == 'delete') {
                        _viewModel.removePage(note.id, page.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.createNote(
                controller.text.isEmpty ? 'Untitled' : controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    String noteId,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.renameNote(noteId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
