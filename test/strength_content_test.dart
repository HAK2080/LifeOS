import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/features/training/strength/strength_content.dart';

void main() {
  test('starter templates are editable and use progressive defaults', () {
    expect(starterTemplates, isNotEmpty);
    expect(starterTemplates.every((t) => t.workouts.isNotEmpty), isTrue);
    expect(
      starterTemplates.expand((t) => t.workouts).expand((w) => w.exercises),
      everyElement(
        predicate<TemplateExercise>((e) => e.repMin <= e.repMax && e.sets > 0),
      ),
    );
  });

  test('volume landmarks describe a set count without pressure language', () {
    final landmark = makeVolumeLandmark('chest', 12);
    expect(landmark.targetLow, 10);
    expect(landmark.targetHigh, 16);
    expect(landmark.guidance, 'Within a useful working range');
    expect(
      makeVolumeLandmark('chest', 0).guidance,
      'No logged sets in this window',
    );
  });
}
