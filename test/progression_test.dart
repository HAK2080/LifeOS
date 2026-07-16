import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/features/training/progression.dart';

void main() {
  ProgressionInput input(List<SetResult> sets,
          {int missed = 0, double inc = 2.5}) =>
      ProgressionInput(
          lastSets: sets,
          priorSessionsMissedTarget: missed,
          smallestIncrementKg: inc);

  test('no history → neutral start', () {
    final r = recommendNext(input([]));
    expect(r.action, ProgressionAction.keepSame);
  });

  test('all sets at top of range → add weight, reset reps', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 12, rir: 1),
      const SetResult(weightKg: 60, reps: 12, rir: 1),
      const SetResult(weightKg: 60, reps: 12, rir: 0),
    ]));
    expect(r.action, ProgressionAction.addWeight);
    expect(r.weightKg, 62.5);
    expect(r.targetReps, 8);
    expect(r.reason, isNotEmpty);
  });

  test('inside range → add a rep at same weight', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 10, rir: 1.5),
      const SetResult(weightKg: 60, reps: 9, rir: 1),
    ]));
    expect(r.action, ProgressionAction.addReps);
    expect(r.weightKg, 60);
    expect(r.targetReps, 10);
  });

  test('inside range but very fresh (RIR 3+) → push two reps', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 10, rir: 3),
      const SetResult(weightKg: 60, reps: 10, rir: 4),
    ]));
    expect(r.action, ProgressionAction.addReps);
    expect(r.targetReps, 12);
  });

  test('below range while grinding → lower one increment', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 6, rir: 0),
      const SetResult(weightKg: 60, reps: 5, rir: 0),
    ]));
    expect(r.action, ProgressionAction.lowerWeight);
    expect(r.weightKg, 57.5);
  });

  test('below range with reps in reserve → repeat same weight', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 7, rir: 2),
    ]));
    expect(r.action, ProgressionAction.keepSame);
    expect(r.weightKg, 60);
  });

  test('third consecutive stall → deload 15%', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 60, reps: 6, rir: 1),
    ], missed: 2));
    expect(r.action, ProgressionAction.deload);
    expect(r.weightKg, 50); // 51 rounded to 2.5 grid
  });

  test('pain overrides everything → back off ~10%', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 100, reps: 12, rir: 3, pain: true),
    ]));
    expect(r.action, ProgressionAction.lowerWeight);
    expect(r.weightKg, 90);
    expect(r.reason, contains('pain'));
  });

  test('respects available weight increments', () {
    final r = recommendNext(input([
      const SetResult(weightKg: 24, reps: 12, rir: 1),
    ], inc: 4)); // kettlebell jumps
    expect(r.weightKg, 28);
  });
}
