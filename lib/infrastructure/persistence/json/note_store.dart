import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../domain/notes/note.dart';
import '../../../domain/pages/page.dart';
import '../../../domain/services/storage_security_service.dart';

class NoteStore {
  NoteStore({
    required Future<Directory> Function() directoryResolver,
    required StorageSecurityService securityService,
  })  : _resolveDirectory = directoryResolver,
        _securityService = securityService;

  final Future<Directory> Function() _resolveDirectory;
  final StorageSecurityService _securityService;

  Future<List<Note>> loadAll() async {
    final file = await _notesFile();
    if (!await file.exists()) {
      return [];
    }
    final ciphertext = await file.readAsBytes();
    final plaintext =
        await _securityService.decrypt(ciphertext, context: 'note_store');
    final List<dynamic> list =
        jsonDecode(utf8.decode(plaintext)) as List<dynamic>;
    return list
        .map((item) => _NoteJsonMapper.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Note> notes) async {
    await _securityService.ensureInitialized();
    final file = await _notesFile();
    final payload = notes.map(_NoteJsonMapper.toMap).toList();
    final plaintext = utf8.encode(jsonEncode(payload));
    final ciphertext =
        await _securityService.encrypt(plaintext, context: 'note_store');
    await file.writeAsBytes(ciphertext, flush: true);
  }

  Future<File> _notesFile() async {
    final dir = await _resolveDirectory();
    return File(p.join(dir.path, 'inkflow_notes.json'));
  }
}

class _NoteJsonMapper {
  static Map<String, dynamic> toMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'pages': note.pages.map(_PageJsonMapper.toMap).toList(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      pages: (map['pages'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_PageJsonMapper.fromMap)
          .toList(),
    );
  }
}

class _PageJsonMapper {
  static Map<String, dynamic> toMap(Page page) {
    return {
      'id': page.id,
      'title': page.title,
      'background': page.background.name,
      'dimensions': {
        'width': page.dimensions.width,
        'height': page.dimensions.height,
      },
      'createdAt': page.createdAt.toIso8601String(),
      'strokeIds': page.strokeIds,
    };
  }

  static Page fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'] as String,
      title: map['title'] as String,
      background: PageBackgroundStyle.values.firstWhere(
        (style) => style.name == map['background'],
        orElse: () => PageBackgroundStyle.blank,
      ),
      dimensions: PageDimensions(
        width: (map['dimensions']['width'] as num).toDouble(),
        height: (map['dimensions']['height'] as num).toDouble(),
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      strokeIds: (map['strokeIds'] as List<dynamic>).cast<String>(),
    );
  }
}
