import 'package:shared_preferences/shared_preferences.dart';

/// Validates weight input within acceptable range.
class WeightValidator {
  static const double minWeight = 30.0;
  static const double maxWeight = 300.0;

  /// Returns null if valid, error message if invalid.
  static String? validate(double? value) {
    if (value == null) return 'Peso é obrigatório';
    if (value < minWeight || value > maxWeight) {
      return 'Peso deve estar entre ${minWeight.toInt()}kg e ${maxWeight.toInt()}kg';
    }
    return null;
  }
}

/// Repository for persisting weight data via SharedPreferences.
class WeightRepository {
  static const String _currentWeightKey = 'current_weight';
  static const String _previousWeightKey = 'previous_weight';

  /// Loads the current stored weight, or null if not set.
  Future<double?> loadWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }

  /// Saves a new weight value, moving the current weight to previous first.
  Future<void> saveWeight(double kg) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_currentWeightKey);
    if (current != null) {
      await prefs.setDouble(_previousWeightKey, current);
    }
    await prefs.setDouble(_currentWeightKey, kg);
  }

  /// Loads the previous weight for delta calculation, or null if not set.
  Future<double?> loadPreviousWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_previousWeightKey);
  }
}
