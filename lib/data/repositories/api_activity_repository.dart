import 'package:oi_coach/data/services/api_client.dart';

class ApiActivityRepository {
  /// Gets activities for a specific day.
  Future<List<dynamic>> getActivitiesForDay(DateTime date) async {
    return await ApiClient.get(
      '/activities',
      queryParams: {'date': date.toIso8601String().substring(0, 10)},
    );
  }

  /// Saves a new activity.
  Future<Map<String, dynamic>> saveActivity({
    required String type,
    required int durationMinutes,
    required String source,
    required DateTime date,
  }) async {
    return await ApiClient.post('/activities', {
      'type': type,
      'durationMinutes': durationMinutes,
      'source': source,
      'date': date.toIso8601String(),
    });
  }

  /// Deletes an activity by ID.
  Future<void> deleteActivity(String id) async {
    await ApiClient.delete('/activities/$id');
  }
}
