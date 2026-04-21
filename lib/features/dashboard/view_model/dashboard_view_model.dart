import 'package:flutter/material.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/repositories/api_weight_repository.dart';
import 'package:oi_coach/data/repositories/api_workout_plan_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';

class DashboardViewModel extends ChangeNotifier {
  late final ApiWorkoutPlanRepository _workoutPlanRepo;
  late final ApiWeightRepository _weightRepo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  WorkoutDay? _todayWorkout;
  WorkoutDay? get todayWorkout => _todayWorkout;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  DashboardViewModel({ApiClient? apiClient}) {
    final client = apiClient ?? ApiClient(TokenService());
    _workoutPlanRepo = ApiWorkoutPlanRepository(client);
    _weightRepo = ApiWeightRepository(client);
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _workoutPlanRepo.getWorkoutPlans(),
        _weightRepo.getLatest(),
      ]);

      final workoutPlans = results[0] as List<dynamic>;
      final weightData = results[1] as ({double? current, double? previous});

      _todayWorkout = _pickTodaysWorkout(_parseWorkoutDays(workoutPlans));
      _currentWeight = weightData.current;
    } catch (_) {
      // On error, leave fields null — view shows empty state
    }

    _isLoading = false;
    notifyListeners();
  }

  List<WorkoutDay> _parseWorkoutDays(List<dynamic> workoutPlans) {
    if (workoutPlans.isEmpty) return [];
    final plan = workoutPlans[0] as Map<String, dynamic>;
    final daysJson = plan['days'] as List<dynamic>? ?? [];
    return daysJson.map((d) {
      final dayMap = d as Map<String, dynamic>;
      final exercisesJson = dayMap['exercises'] as List<dynamic>? ?? [];
      return WorkoutDay(
        id: dayMap['id'] ?? '',
        name: dayMap['name'] ?? '',
        focus: dayMap['focus'] ?? '',
        day: dayMap['day'] ?? '',
        exercises: exercisesJson.map((e) {
          final exMap = e as Map<String, dynamic>;
          return Exercise(
            id: exMap['id'] ?? '',
            order: exMap['order'] ?? 0,
            name: exMap['name'] ?? '',
            targetSets: exMap['targetSets'] ?? 0,
            targetReps: (exMap['targetReps'] ?? '0').toString(),
            targetWeight: (exMap['targetWeight'] ?? 0).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

  WorkoutDay? _pickTodaysWorkout(List<WorkoutDay> days) {
    if (days.isEmpty) return null;
    const weekdayNames = {
      1: 'Segunda',
      2: 'Terça',
      3: 'Quarta',
      4: 'Quinta',
      5: 'Sexta',
      6: 'Sábado',
      7: 'Domingo',
    };
    final todayName = weekdayNames[DateTime.now().weekday] ?? '';
    for (final d in days) {
      if (d.day.toLowerCase() == todayName.toLowerCase()) return d;
    }
    return days.first;
  }
}
