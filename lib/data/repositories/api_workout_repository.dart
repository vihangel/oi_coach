import 'package:oi_coach/data/services/api_client.dart';

class ApiWorkoutRepository {
  /// Saves a workout session to the backend.
  Future<Map<String, dynamic>> saveWorkout({
    required DateTime date,
    required String workoutDayId,
    required String workoutName,
    required String focus,
    required List<Map<String, dynamic>> exercises,
  }) async {
    return await ApiClient.post('/workouts', {
      'date': date.toIso8601String(),
      'workoutDayId': workoutDayId,
      'workoutName': workoutName,
      'focus': focus,
      'exercises': exercises,
    });
  }

  /// Gets workout logs, optionally filtered by date.
  Future<List<dynamic>> getWorkouts({DateTime? date}) async {
    final params = <String, String>{};
    if (date != null) {
      params['date'] = date.toIso8601String().substring(0, 10);
    }
    return await ApiClient.get('/workouts', queryParams: params);
  }

  /// Gets last 2 weeks of workouts for progress comparison.
  Future<List<dynamic>> getLatestWorkouts() async {
    return await ApiClient.get('/workouts/latest');
  }
}
