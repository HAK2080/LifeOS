/// Plan text import — pure Dart, testable.
///
/// Accepted shape (forgiving):
/// ```
/// Upper A:
/// Bench Press 3x8-12
/// Barbell Row 3 x 10
///
/// Lower A:
/// Back Squat 4x5
/// ```
/// A line ending with ':' (or starting with '#') names a workout; other
/// non-empty lines are exercises as `<name> <sets>x<reps>[-<repMax>]`.
library;

class ImportedExercise {
  const ImportedExercise(this.name, this.sets, this.repMin, this.repMax);

  final String name;
  final int sets;
  final int? repMin;
  final int? repMax;
}

class ImportedWorkout {
  const ImportedWorkout(this.name, this.exercises);

  final String name;
  final List<ImportedExercise> exercises;
}

final _exerciseLine = RegExp(
    r'^(.*?)[\s|:]+(\d+)\s*[x×*]\s*(\d+)(?:\s*[-–]\s*(\d+))?\s*$');

List<ImportedWorkout> parsePlanText(String text) {
  final workouts = <ImportedWorkout>[];
  String? currentName;
  var current = <ImportedExercise>[];

  void flush() {
    if (current.isNotEmpty || currentName != null) {
      workouts.add(ImportedWorkout(
          currentName ?? 'Workout ${workouts.length + 1}', current));
    }
    current = [];
    currentName = null;
  }

  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    final isHeader = line.endsWith(':') || line.startsWith('#');
    if (isHeader) {
      flush();
      currentName = line.replaceAll(RegExp(r'^#+\s*|:$'), '').trim();
      continue;
    }

    final m = _exerciseLine.firstMatch(line);
    if (m != null) {
      final name = m.group(1)!.trim().replaceAll(RegExp(r'[|,-]+$'), '').trim();
      current.add(ImportedExercise(
        name,
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
        m.group(4) == null ? null : int.parse(m.group(4)!),
      ));
    } else {
      // A bare line with no sets info: treat as exercise with defaults.
      current.add(ImportedExercise(line, 3, null, null));
    }
  }
  flush();
  return workouts.where((w) => w.exercises.isNotEmpty).toList();
}
