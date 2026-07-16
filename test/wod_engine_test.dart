import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/features/training/wod/wod_engine.dart';
import 'package:life_app/features/training/wod/wod_library.dart';

void main() {
  test('only uses available equipment (or bodyweight)', () {
    final wod = generateWod(
      const WodRequest(
        durationMin: 15,
        difficulty: Difficulty.moderate,
        availableEquipment: {'Kettlebells'},
      ),
      seed: 42,
    );
    for (final m in wod.movements) {
      expect(m.movement.equipment == null ||
          m.movement.equipment == 'Kettlebells', isTrue,
          reason: '${m.movement.name} needs ${m.movement.equipment}');
    }
  });

  test('knee-safe filter excludes knee-heavy movements', () {
    final wod = generateWod(
      const WodRequest(
        durationMin: 20,
        difficulty: Difficulty.moderate,
        availableEquipment: {
          'Kettlebells', 'Dumbbells', 'Plyometric boxes', 'Air rower'
        },
        kneeSafeOnly: true,
      ),
      seed: 7,
    );
    for (final m in wod.movements) {
      expect(m.movement.kneeSafe, isTrue,
          reason: '${m.movement.name} is not knee-safe');
    }
  });

  test('feeling tired steps difficulty down (fewer reps)', () {
    const base = WodRequest(
      durationMin: 15,
      difficulty: Difficulty.moderate,
      availableEquipment: {'Kettlebells', 'Dumbbells'},
    );
    final normal = generateWod(base, seed: 3);
    final tired = generateWod(
      const WodRequest(
        durationMin: 15,
        difficulty: Difficulty.moderate,
        availableEquipment: {'Kettlebells', 'Dumbbells'},
        feeling: 'tired',
      ),
      seed: 3,
    );
    expect(tired.difficulty, Difficulty.easy);
    final normalTotal =
        normal.movements.fold(0, (s, m) => s + m.reps);
    final tiredTotal = tired.movements.fold(0, (s, m) => s + m.reps);
    expect(tiredTotal, lessThan(normalTotal));
  });

  test('every generated WOD explains itself', () {
    final wod = generateWod(
      const WodRequest(
        durationMin: 25,
        difficulty: Difficulty.hard,
        availableEquipment: {'Air rower', 'Kettlebells'},
      ),
      seed: 11,
    );
    expect(wod.purpose, isNotEmpty);
    expect(wod.stimulus, isNotEmpty);
    expect(wod.workRest, isNotEmpty);
    expect(wod.description, contains('Scaling'));
    expect(wod.description, contains('Substitutions'));
    expect(wod.movements.length, greaterThanOrEqualTo(2));
  });

  test('no equipment at all falls back to bodyweight', () {
    final wod = generateWod(
      const WodRequest(
        durationMin: 12,
        difficulty: Difficulty.easy,
        availableEquipment: {},
        kneeSafeOnly: true,
      ),
      seed: 5,
    );
    expect(wod.movements, isNotEmpty);
    for (final m in wod.movements) {
      expect(m.movement.equipment, isNull);
    }
  });

  test('avoids repeating completed titles when possible', () {
    final done = {'Ember', 'Drift', 'Anchor', 'Summit', 'Harbor', 'Cedar'};
    final wod = generateWod(
      WodRequest(
        durationMin: 15,
        difficulty: Difficulty.moderate,
        availableEquipment: const {'Kettlebells'},
        avoidTitles: done,
      ),
      seed: 1,
    );
    expect(done.contains(wod.title), isFalse);
  });

  test('library entries are complete', () {
    for (final w in wodLibrary) {
      expect(w.name, isNotEmpty);
      expect(['beginner', 'intermediate', 'advanced'], contains(w.level));
      expect(w.durationMin, greaterThan(0));
      expect(w.description, isNotEmpty);
    }
  });
}
