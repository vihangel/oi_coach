/// Model representing an exercise's progress between two weeks.
///
/// Tracks weight (carga) and repetitions (reps) for both the previous
/// and current week, providing computed deltas and progression/regression indicators.
class ExerciseProgressEntry {
  final String exerciseId;
  final String exerciseName;
  final double previousWeight; // kg semana anterior
  final int previousReps; // reps semana anterior
  final double currentWeight; // kg semana atual
  final int currentReps; // reps semana atual

  const ExerciseProgressEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.previousWeight,
    required this.previousReps,
    required this.currentWeight,
    required this.currentReps,
  });

  /// Diferença de carga entre semana atual e anterior.
  double get weightDelta => currentWeight - previousWeight;

  /// Diferença de repetições entre semana atual e anterior.
  int get repsDelta => currentReps - previousReps;

  /// Verde: peso OU reps melhorou.
  bool get hasProgression => weightDelta > 0 || repsDelta > 0;

  /// Vermelho: peso E reps pioraram.
  bool get hasRegression => weightDelta < 0 && repsDelta < 0;
}
