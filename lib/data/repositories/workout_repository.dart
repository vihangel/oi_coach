import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart' as mock;

/// Abstraction for workout data access.
/// Currently backed by mock data — swap to remote/local later.
class WorkoutRepository {
  List<WorkoutDay> getWorkoutPlan() => mock.workoutPlan;

  Map<String, List<ExerciseSet>> getLastWeekResults() => mock.lastWeekResults;

  Future<void> saveSession(WorkoutSession session) async {
    // TODO: persist to local DB or remote API
  }
}
