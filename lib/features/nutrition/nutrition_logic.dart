/// Nutrition targets and weight trend — pure Dart, testable.
library;

class Profile {
  const Profile({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    this.isMale = true,
    this.activity = ActivityLevel.moderate,
    this.goal = Goal.maintain,
  });

  final double weightKg;
  final double heightCm;
  final int age;
  final bool isMale;
  final ActivityLevel activity;
  final Goal goal;
}

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { loseFat, buildMuscle, recomposition, maintain, generalHealth }

class MacroTargets {
  const MacroTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.explanation,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  /// Transparency: how the numbers were derived, in one short paragraph.
  final String explanation;
}

/// Mifflin-St Jeor BMR × activity factor, adjusted for goal.
/// Suggested only — never applied automatically.
MacroTargets suggestTargets(Profile p) {
  final bmr = 10 * p.weightKg +
      6.25 * p.heightCm -
      5 * p.age +
      (p.isMale ? 5 : -161);

  final factor = switch (p.activity) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.light => 1.375,
    ActivityLevel.moderate => 1.55,
    ActivityLevel.active => 1.725,
    ActivityLevel.veryActive => 1.9,
  };
  final tdee = bmr * factor;

  final (adjustment, goalNote) = switch (p.goal) {
    Goal.loseFat => (-0.15, 'a gentle 15% deficit for fat loss'),
    Goal.buildMuscle => (0.10, 'a 10% surplus to support muscle'),
    Goal.recomposition => (-0.05, 'a slight deficit for recomposition'),
    Goal.maintain => (0.0, 'maintenance'),
    Goal.generalHealth => (0.0, 'maintenance for general health'),
  };
  final calories = (tdee * (1 + adjustment)).round();

  // Protein: 1.8 g/kg (muscle-preserving, practical). Fat: 25% of calories.
  final proteinG = (1.8 * p.weightKg).round();
  final fatG = (calories * 0.25 / 9).round();
  final carbsG = ((calories - proteinG * 4 - fatG * 9) / 4).round();

  return MacroTargets(
    calories: calories,
    proteinG: proteinG,
    carbsG: carbsG < 0 ? 0 : carbsG,
    fatG: fatG,
    explanation:
        'Estimated from your weight, height, age and activity (BMR ≈ ${bmr.round()} kcal, '
        'daily burn ≈ ${tdee.round()} kcal), set to $goalNote. Protein at 1.8 g/kg, '
        'fat at 25% of calories, carbs fill the rest. Adjust anything — these are suggestions.',
  );
}

/// Exponentially smoothed weight trend (like a gentle moving average).
/// Returns the trend value per entry, oldest first.
List<double> weightTrend(List<double> weights, {double alpha = 0.3}) {
  if (weights.isEmpty) return const [];
  final trend = <double>[weights.first];
  for (var i = 1; i < weights.length; i++) {
    trend.add(alpha * weights[i] + (1 - alpha) * trend[i - 1]);
  }
  return trend;
}

/// Whether there is enough logging history to responsibly suggest a target
/// change (prefer at least two weeks of usable data).
bool enoughDataForTargetChange(Set<String> daysWithLogs, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var count = 0;
  for (var i = 0; i < 14; i++) {
    final d = today.subtract(Duration(days: i));
    final key =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (daysWithLogs.contains(key)) count++;
  }
  return count >= 10; // 10 of the last 14 days logged
}

/// Portion multipliers offered in the UI: −20%, −10%, same, +10%, +20%.
const portionSteps = [0.8, 0.9, 1.0, 1.1, 1.2];
