import 'dart:convert';

import 'package:oi_coach/core/models/extra_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Validates activity duration input.
class ActivityValidator {
  /// Returns null if valid, error message if invalid.
  static String? validateDuration(int? minutes) {
    if (minutes == null || minutes <= 0) return 'Duração deve ser maior que 0';
    return null;
  }
}

/// Repository for persisting extra activities via SharedPreferences.
///
/// Activities are stored as a JSON-encoded list per day, keyed by date
/// in the format 'activities_YYYY-MM-DD'.
class ActivityRepository {
  /// Builds the SharedPreferences key for a given date.
  static String _keyForDate(DateTime date) {
    final d = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    return 'activities_$d';
  }

  /// Loads all activities for a given day.
  Future<List<ExtraActivity>> getActivitiesForDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ExtraActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves a new activity, appending it to the day's list.
  Future<void> saveActivity(ExtraActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(activity.date);
    final existing = await getActivitiesForDay(activity.date);
    existing.add(activity);
    final encoded = jsonEncode(existing.map((a) => a.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Deletes an activity by id from its day's list.
  Future<void> deleteActivity(String id) async {
    final prefs = await SharedPreferences.getInstance();
    // We need to search all keys since we only have the id.
    // For efficiency, callers should use deleteActivityForDay when date is known.
    final keys = prefs.getKeys().where((k) => k.startsWith('activities_'));
    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final filtered = decoded
          .where((e) => (e as Map<String, dynamic>)['id'] != id)
          .toList();
      if (filtered.length != decoded.length) {
        await prefs.setString(key, jsonEncode(filtered));
        return;
      }
    }
  }
}
