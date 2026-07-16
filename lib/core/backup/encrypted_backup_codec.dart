import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Password-protected envelope for a local JSON backup.
///
/// PBKDF2 derives an AES-256-GCM key from the user's password. The salt and
/// nonce are stored with the ciphertext; neither is secret. The plaintext
/// JSON is never written to disk by this codec.
class EncryptedBackupCodec {
  const EncryptedBackupCodec();

  static const _format = 'life-encrypted-backup';
  static const _version = 1;
  static const _iterations = 120000;

  Future<String> encrypt(String plaintext, String password) async {
    _checkPassword(password);
    final salt = await SecretKeyData.random(length: 16).extractBytes();
    final key = await _derive(password, salt);
    final cipher = AesGcm.with256bits();
    final box = await cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    return const JsonEncoder.withIndent('  ').convert({
      'format': _format,
      'version': _version,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<String> decrypt(String source, String password) async {
    _checkPassword(password);
    final decoded = jsonDecode(source);
    if (decoded is! Map || decoded['format'] != _format || decoded['version'] != 1) {
      throw const FormatException('Not a supported encrypted Life backup');
    }
    if (decoded['kdf'] != 'PBKDF2-HMAC-SHA256' ||
        decoded['iterations'] != _iterations) {
      throw const FormatException('Unsupported encryption parameters');
    }
    try {
      final salt = base64Decode(decoded['salt'] as String);
      final key = await _derive(password, salt);
      final box = SecretBox(
        base64Decode(decoded['ciphertext'] as String),
        nonce: base64Decode(decoded['nonce'] as String),
        mac: Mac(base64Decode(decoded['mac'] as String)),
      );
      final clear = await AesGcm.with256bits().decrypt(box, secretKey: key);
      return utf8.decode(clear);
    } catch (_) {
      throw const FormatException('Password is incorrect or backup is damaged');
    }
  }

  Future<SecretKey> _derive(String password, List<int> salt) {
    return Pbkdf2.hmacSha256(iterations: _iterations, bits: 256)
        .deriveKeyFromPassword(password: password, nonce: salt);
  }

  void _checkPassword(String password) {
    if (password.length < 8) {
      throw const FormatException('Use a backup password of at least 8 characters');
    }
  }
}
