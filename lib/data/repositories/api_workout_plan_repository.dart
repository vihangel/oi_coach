import 'package:oi_coach/data/services/api_client.dart';

class ApiWorkoutPlanRepository {
  final ApiClient _apiClient;

  ApiWorkoutPlanRepository(this._apiClient);

  /// Gets all workout plans for the authenticated user.
  Future<List<dynamic>> getWorkoutPlans() async {
    return await _apiClient.get('/workout-plans');
  }

  /// Creates a new workout plan for the authenticated user.
  Future<Map<String, dynamic>> createWorkoutPlan(
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.post('/workout-plans', data);
  }

  /// Updates an existing workout plan by [id].
  Future<Map<String, dynamic>> updateWorkoutPlan(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.put('/workout-plans/$id', data);
  }
}
