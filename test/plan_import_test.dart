import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/features/training/strength/plan_import.dart';

void main() {
  test('parses workouts with headers and rep ranges', () {
    final result = parsePlanText('''
Upper A:
Bench Press 3x8-12
Barbell Row 3 x 10

Lower A:
Back Squat 4x5
Romanian Deadlift 3×8–10
''');
    expect(result.length, 2);
    expect(result[0].name, 'Upper A');
    expect(result[0].exercises.length, 2);
    expect(result[0].exercises[0].name, 'Bench Press');
    expect(result[0].exercises[0].sets, 3);
    expect(result[0].exercises[0].repMin, 8);
    expect(result[0].exercises[0].repMax, 12);
    expect(result[0].exercises[1].repMax, isNull);
    expect(result[1].exercises[1].name, 'Romanian Deadlift');
    expect(result[1].exercises[1].repMin, 8);
    expect(result[1].exercises[1].repMax, 10);
  });

  test('headerless text becomes one workout', () {
    final result = parsePlanText('Squat 5x5\nBench 5x5');
    expect(result.length, 1);
    expect(result[0].exercises.length, 2);
  });

  test('markdown-style headers work', () {
    final result = parsePlanText('# Push Day\nOverhead Press 4x6');
    expect(result[0].name, 'Push Day');
  });

  test('bare exercise lines default to 3 sets', () {
    final result = parsePlanText('Plank');
    expect(result[0].exercises[0].sets, 3);
    expect(result[0].exercises[0].repMin, isNull);
  });

  test('empty input → no workouts', () {
    expect(parsePlanText(''), isEmpty);
    expect(parsePlanText('\n\n'), isEmpty);
  });
}
