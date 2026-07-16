import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/features/today/today_data.dart';

void main() {
  group('rotationIndex', () {
    test('is stable within a day', () {
      final morning = DateTime(2026, 7, 16, 6);
      final night = DateTime(2026, 7, 16, 23);
      expect(rotationIndex(morning, 30), rotationIndex(night, 30));
    });

    test('changes from one day to the next', () {
      final today = DateTime(2026, 7, 16);
      final tomorrow = DateTime(2026, 7, 17);
      expect(rotationIndex(today, 30), isNot(rotationIndex(tomorrow, 30)));
    });

    test('stays within bounds', () {
      for (var d = 1; d <= 365; d++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: d));
        final i = rotationIndex(date, 6);
        expect(i, inInclusiveRange(0, 5));
      }
    });
  });

  test('dayKey formats yyyy-MM-dd', () {
    expect(dayKey(DateTime(2026, 7, 6)), '2026-07-06');
  });
}
