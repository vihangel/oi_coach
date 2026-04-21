class Exercise {
  final String id;
  final String name;
  final int targetSets;
  final String targetReps;
  final double targetWeight;
  final int order;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.targetWeight,
    required this.order,
  });
}

class ExerciseSet {
  final int reps;
  final double weight;

  const ExerciseSet({required this.reps, required this.weight});
}
