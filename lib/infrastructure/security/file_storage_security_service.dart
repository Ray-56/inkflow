import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart' as p;

import '../../domain/services/storage_security_service.dart';

class FileStorageSecurityService implements StorageSecurityService {
  FileStorageSecurityService({
    required Future<Directory> Function() directoryResolver,
  }) : _resolveDirectory = directoryResolver;

  final Future<Directory> Function() _resolveDirectory;
  bool _initialized = false;
  late List<int> _keyBytes;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final dir = await _resolveDirectory();
    final file = File(p.join(dir.path, 'inkflow.key'));
    if (await file.exists()) {
      final data = await file.readAsString();
      _keyBytes = base64Decode(data);
    } else {
      final rand = Random.secure();
      _keyBytes = List<int>.generate(32, (_) => rand.nextInt(256));
      await file.writeAsString(base64Encode(_keyBytes), flush: true);
    }
    _initialized = true;
  }

  @override
  Future<List<int>> encrypt(List<int> plaintext, {String? context}) async {
    await ensureInitialized();
    final iv = _generateIv();
    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(Uint8List.fromList(_keyBytes))));
    final encrypted = encrypter.encryptBytes(
      plaintext,
      iv: enc.IV(Uint8List.fromList(iv)),
    );
    return [...iv, ...encrypted.bytes];
  }

  @override
  Future<List<int>> decrypt(List<int> ciphertext, {String? context}) async {
    await ensureInitialized();
    if (ciphertext.length < 16) {
      throw const FormatException('Invalid ciphertext');
    }
    final iv = ciphertext.sublist(0, 16);
    final payload = ciphertext.sublist(16);
    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(Uint8List.fromList(_keyBytes))));
    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(Uint8List.fromList(payload)),
      iv: enc.IV(Uint8List.fromList(iv)),
    );
    return decrypted;
  }

  @override
  Future<void> rotateKeys() async {
    _initialized = false;
    await ensureInitialized();
  }

  List<int> _generateIv() {
    final rand = Random.secure();
    return List<int>.generate(16, (_) => rand.nextInt(256));
  }
}
