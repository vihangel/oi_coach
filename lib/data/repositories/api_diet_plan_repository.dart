import 'package:oi_coach/data/services/api_client.dart';

class ApiDietPlanRepository {
  final ApiClient _apiClient;

  ApiDietPlanRepository(this._apiClient);

  /// Gets all diet plans for the authenticated user.
  Future<List<dynamic>> getDietPlans() async {
    return await _apiClient.get('/diet-plans');
  }

  /// Creates a new diet plan for the authenticated user.
  Future<Map<String, dynamic>> createDietPlan(Map<String, dynamic> data) async {
    return await _apiClient.post('/diet-plans', data);
  }

  /// Updates an existing diet plan by [id].
  Future<Map<String, dynamic>> updateDietPlan(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.put('/diet-plans/$id', data);
  }
}
