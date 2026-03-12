import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/services/storage_security_service.dart';
import '../../domain/strokes/stroke.dart';
import '../../domain/strokes/stroke_point.dart';
import '../../domain/strokes/stroke_repository.dart';
import '../../domain/tools/drawing_tool.dart';

class StrokeRepositoryImpl implements StrokeRepository {
  StrokeRepositoryImpl({
    required Future<Directory> Function() directoryResolver,
    required StorageSecurityService securityService,
  })  : _resolveDirectory = directoryResolver,
        _securityService = securityService;

  final Future<Directory> Function() _resolveDirectory;
  final StorageSecurityService _securityService;

  @override
  Future<List<Stroke>> loadAll(String noteId, String pageId) async {
    final file = await _file(noteId, pageId);
    if (!await file.exists()) {
      return [];
    }
    final ciphertext = await file.readAsBytes();
    final plaintext =
        await _securityService.decrypt(ciphertext, context: 'stroke_store');
    final List<dynamic> payload =
        jsonDecode(utf8.decode(plaintext)) as List<dynamic>;
    return payload
        .map((item) => _StrokeMapper.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(
    String noteId,
    String pageId,
    List<Stroke> strokes,
  ) async {
    await _securityService.ensureInitialized();
    final file = await _file(noteId, pageId);
    final payload = strokes.map(_StrokeMapper.toMap).toList();
    final plaintext = utf8.encode(jsonEncode(payload));
    final ciphertext =
        await _securityService.encrypt(plaintext, context: 'stroke_store');
    await file.writeAsBytes(ciphertext, flush: true);
  }

  Future<File> _file(String noteId, String pageId) async {
    final dir = await _resolveDirectory();
    return File(p.join(dir.path, '${noteId}_$pageId.strokes'));
  }
}

class _StrokeMapper {
  static Map<String, dynamic> toMap(Stroke stroke) {
    return {
      'id': stroke.id,
      'pageId': stroke.pageId,
      'tool': {
        'type': stroke.tool.type.name,
        'color': stroke.tool.color,
        'width': stroke.tool.width,
        'opacity': stroke.tool.opacity,
      },
      'points': stroke.points
          .map(
            (point) => {
              'x': point.x,
              'y': point.y,
              'pressure': point.pressure,
              'tilt': point.tilt,
              'timestamp': point.timestamp.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  static Stroke fromMap(Map<String, dynamic> map) {
    return Stroke(
      id: map['id'] as String,
      pageId: map['pageId'] as String,
      tool: DrawingTool(
        type: DrawingToolType.values.firstWhere(
          (type) => type.name == map['tool']['type'],
          orElse: () => DrawingToolType.pen,
        ),
        color: map['tool']['color'] as int,
        width: (map['tool']['width'] as num).toDouble(),
        opacity: (map['tool']['opacity'] as num).toDouble(),
      ),
      points: (map['points'] as List<dynamic>)
          .map(
            (point) => StrokePoint(
              x: (point['x'] as num).toDouble(),
              y: (point['y'] as num).toDouble(),
              pressure: (point['pressure'] as num).toDouble(),
              tilt: (point['tilt'] as num).toDouble(),
              timestamp: DateTime.parse(point['timestamp'] as String),
            ),
          )
          .toList(),
    );
  }
}
