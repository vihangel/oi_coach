import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/services/api_client.dart';

class ApiProgressRepository {
  /// Gets progress comparison entries from the backend.
  Future<List<ExerciseProgressEntry>> getProgress() async {
    final data = await ApiClient.get('/progress');
    final entries = data['entries'] as List<dynamic>;
    return entries
        .map(
          (e) => ExerciseProgressEntry(
            exerciseId: e['exerciseId'],
            exerciseName: e['exerciseName'],
            previousWeight: (e['previousWeight'] as num).toDouble(),
            previousReps: (e['previousReps'] as num).toInt(),
            currentWeight: (e['currentWeight'] as num).toDouble(),
            currentReps: (e['currentReps'] as num).toInt(),
          ),
        )
        .toList();
  }
}
