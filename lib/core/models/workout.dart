import 'exercise.dart';

class WorkoutDay {
  final String id;
  final String name;
  final String focus;
  final String day;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.id,
    required this.name,
    required this.focus,
    required this.day,
    required this.exercises,
  });
}

class WorkoutSession {
  final String id;
  final String workoutDayId;
  final DateTime date;
  final Map<String, List<ExerciseSet>> sets;

  const WorkoutSession({
    required this.id,
    required this.workoutDayId,
    required this.date,
    required this.sets,
  });
}
