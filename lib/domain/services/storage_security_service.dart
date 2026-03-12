/// Abstraction that hides encryption/decryption for persisted note data.
abstract class StorageSecurityService {
  /// Ensures keys or secure enclaves are ready before read/write operations.
  Future<void> ensureInitialized();

  /// Encrypts [plaintext] and returns ciphertext bytes.
  Future<List<int>> encrypt(List<int> plaintext, {String? context});

  /// Decrypts [ciphertext] and returns plaintext bytes.
  Future<List<int>> decrypt(List<int> ciphertext, {String? context});

  /// Optional hook to rotate keys or refresh credentials.
  Future<void> rotateKeys();

  bool get isInitialized;
}
