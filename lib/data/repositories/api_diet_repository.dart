import 'package:oi_coach/data/services/api_client.dart';

class ApiDietRepository {
  /// Saves a diet log for the day.
  Future<Map<String, dynamic>> saveDietLog({
    required DateTime date,
    required List<Map<String, dynamic>> checkIns,
    required List<Map<String, dynamic>> freeMeals,
    required List<Map<String, dynamic>> cheatEntries,
  }) async {
    return await ApiClient.post('/diet', {
      'date': date.toIso8601String(),
      'checkIns': checkIns,
      'freeMeals': freeMeals,
      'cheatEntries': cheatEntries,
    });
  }

  /// Gets diet logs, optionally filtered by date.
  Future<List<dynamic>> getDietLogs({DateTime? date}) async {
    final params = <String, String>{};
    if (date != null) {
      params['date'] = date.toIso8601String().substring(0, 10);
    }
    return await ApiClient.get('/diet', queryParams: params);
  }

  /// Updates an existing diet log.
  Future<Map<String, dynamic>> updateDietLog(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await ApiClient.put('/diet/$id', data);
  }
}
