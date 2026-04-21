import 'package:oi_coach/data/services/api_client.dart';

class ApiWeightRepository {
  /// Gets the latest weight entry and previous for delta calculation.
  Future<({double? current, double? previous})> getLatest() async {
    final data = await ApiClient.get('/weight/latest');
    final current = data['current'] != null
        ? (data['current']['value'] as num).toDouble()
        : null;
    final previous = data['previous'] != null
        ? (data['previous']['value'] as num).toDouble()
        : null;
    return (current: current, previous: previous);
  }

  /// Saves a new weight entry.
  Future<void> saveWeight(double value, {DateTime? date}) async {
    await ApiClient.post('/weight', {
      'value': value,
      'date': (date ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Gets weight history.
  Future<List<dynamic>> getHistory({int limit = 30}) async {
    return await ApiClient.get(
      '/weight/history',
      queryParams: {'limit': limit.toString()},
    );
  }
}
