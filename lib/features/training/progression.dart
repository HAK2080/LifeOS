/// Progression engine — pure Dart, no Flutter imports.
///
/// Principles (inspired by RP Strength / JuggernautAI, implemented
/// independently): double progression inside a rep range, autoregulated by
/// RIR and pain. Recommendations are optional, editable and explained.
library;

enum ProgressionAction {
  addReps,
  addWeight,
  keepSame,
  lowerWeight,
  reduceSets,
  deload,
}

class SetResult {
  const SetResult({required this.weightKg, required this.reps, this.rir, this.pain = false});

  final double weightKg;
  final int reps;
  final double? rir;
  final bool pain;
}

class ProgressionInput {
  const ProgressionInput({
    required this.lastSets,
    this.repMin = 8,
    this.repMax = 12,
    this.smallestIncrementKg = 2.5,
    this.priorSessionsMissedTarget = 0,
  });

  /// Sets from the most recent session of this exercise, in order.
  final List<SetResult> lastSets;
  final int repMin;
  final int repMax;

  /// Smallest weight jump available (dumbbell/plate increments).
  final double smallestIncrementKg;

  /// How many consecutive earlier sessions also failed to hit [repMin]
  /// (used to suggest a deload after repeated stalls).
  final int priorSessionsMissedTarget;
}

class Recommendation {
  const Recommendation({
    required this.action,
    required this.weightKg,
    required this.targetReps,
    required this.reason,
  });

  final ProgressionAction action;
  final double weightKg;
  final int targetReps;

  /// One short sentence, shown to the user — transparency requirement.
  final String reason;
}

/// Double progression with RIR/pain autoregulation.
Recommendation recommendNext(ProgressionInput input) {
  final sets = input.lastSets;
  if (sets.isEmpty) {
    return const Recommendation(
      action: ProgressionAction.keepSame,
      weightKg: 0,
      targetReps: 0,
      reason: 'No previous data — start where it feels controlled.',
    );
  }

  final weight = sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
  final minReps = sets.map((s) => s.reps).reduce((a, b) => a < b ? a : b);
  final rirs = sets.where((s) => s.rir != null).map((s) => s.rir!).toList();
  final avgRir = rirs.isEmpty
      ? null
      : rirs.reduce((a, b) => a + b) / rirs.length;
  final hadPain = sets.any((s) => s.pain);

  // Pain overrides everything: back off and flag it.
  if (hadPain) {
    return Recommendation(
      action: ProgressionAction.lowerWeight,
      weightKg: _round(weight * 0.9, input.smallestIncrementKg),
      targetReps: input.repMin,
      reason: 'You flagged pain last time — drop ~10% and rebuild pain-free.',
    );
  }

  // Repeated stalls → deload.
  if (minReps < input.repMin && input.priorSessionsMissedTarget >= 2) {
    return Recommendation(
      action: ProgressionAction.deload,
      weightKg: _round(weight * 0.85, input.smallestIncrementKg),
      targetReps: input.repMin,
      reason:
          'Three sessions below the rep range — a light week (−15%) will help you rebound.',
    );
  }

  // Below rep range → lower weight slightly.
  if (minReps < input.repMin) {
    // Grinding (RIR 0) below range earns a small cut; otherwise repeat.
    if (avgRir != null && avgRir <= 0.5) {
      return Recommendation(
        action: ProgressionAction.lowerWeight,
        weightKg: _round(weight - input.smallestIncrementKg, input.smallestIncrementKg),
        targetReps: input.repMin,
        reason:
            'Reps fell below ${input.repMin} at RIR 0 — one increment lighter keeps quality high.',
      );
    }
    return Recommendation(
      action: ProgressionAction.keepSame,
      weightKg: weight,
      targetReps: input.repMin,
      reason: 'Just under the rep range — same weight, aim for ${input.repMin}+.',
    );
  }

  // At top of range with reps to spare → add weight.
  if (minReps >= input.repMax) {
    return Recommendation(
      action: ProgressionAction.addWeight,
      weightKg: _round(weight + input.smallestIncrementKg, input.smallestIncrementKg),
      targetReps: input.repMin,
      reason:
          'All sets hit ${input.repMax} — add ${_fmt(input.smallestIncrementKg)} kg and work back up from ${input.repMin}.',
    );
  }

  // Inside range, very fresh (RIR ≥ 3) → can skip ahead a rep or weight.
  if (avgRir != null && avgRir >= 3) {
    return Recommendation(
      action: ProgressionAction.addReps,
      weightKg: weight,
      targetReps: (minReps + 2).clamp(input.repMin, input.repMax),
      reason:
          'RIR ${avgRir.toStringAsFixed(0)} means you had plenty in reserve — push +2 reps.',
    );
  }

  // Inside range → add a rep (double progression default).
  return Recommendation(
    action: ProgressionAction.addReps,
    weightKg: weight,
    targetReps: (minReps + 1).clamp(input.repMin, input.repMax),
    reason: 'Inside the rep range — add one rep per set at the same weight.',
  );
}

double _round(double weight, double increment) {
  if (increment <= 0) return weight;
  final steps = (weight / increment).round();
  final result = steps * increment;
  return result < increment ? increment : result;
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
