import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_app/core/backup/encrypted_backup_codec.dart';

void main() {
  const codec = EncryptedBackupCodec();

  test('encrypts and decrypts a backup with the correct password', () async {
    final encrypted = await codec.encrypt('{"hello":"life"}', 'correct horse');
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;

    expect(envelope['format'], 'life-encrypted-backup');
    expect(envelope['ciphertext'], isNot(contains('hello')));
    expect(await codec.decrypt(encrypted, 'correct horse'), '{"hello":"life"}');
  });

  test('rejects a wrong password', () async {
    final encrypted = await codec.encrypt('private', 'correct horse');
    expect(
      () => codec.decrypt(encrypted, 'wrong password'),
      throwsA(isA<FormatException>()),
    );
  });
}
