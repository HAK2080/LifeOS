import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled ayah dataset parses and every entry is complete', () async {
    final raw = await rootBundle.loadString('assets/data/ayah_of_day.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    expect(data['source'], isA<String>());
    final verses = data['verses'] as List;
    expect(verses.length, greaterThanOrEqualTo(30));

    for (final v in verses.cast<Map<String, dynamic>>()) {
      expect(v['surah'], isA<String>());
      expect(v['surah_number'], isA<int>());
      expect(v['ayah_number'], isA<int>());
      expect((v['text'] as String).isNotEmpty, isTrue);
      expect((v['tafsir'] as String).isNotEmpty, isTrue);
    }
  });
}
