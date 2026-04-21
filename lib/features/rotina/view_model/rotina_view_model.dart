import 'package:flutter/material.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/repositories/api_activity_repository.dart';
import 'package:oi_coach/data/repositories/api_diet_plan_repository.dart';
import 'package:oi_coach/data/repositories/api_diet_repository.dart';
import 'package:oi_coach/data/repositories/api_workout_plan_repository.dart';
import 'package:oi_coach/data/repositories/api_workout_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';

class RotinaViewModel extends ChangeNotifier {
  late final ApiWorkoutRepository _workoutRepo;
  late final ApiDietRepository _dietRepo;
  late final ApiActivityRepository _activityRepo;
  late final ApiWorkoutPlanRepository _workoutPlanRepo;
  late final ApiDietPlanRepository _dietPlanRepo;

  // --- Loading / empty state ---
  bool _isLoading = true;
  bool _isEmpty = false;
  bool get isLoading => _isLoading;
  bool get isEmpty => _isEmpty;

  // --- Training state ---
  WorkoutDay? _day;
  WorkoutDay? get day => _day;
  List<DietMeal> _dietPlan = [];
  List<DietMeal> get dietPlan => _dietPlan;
  Map<String, List<ExerciseSet>> _lastWeekResults = {};

  final Map<String, bool> _confirmed = {};
  final Map<String, List<SetInput>> _sets = {};

  // --- Diet state ---
  final Map<String, MealCheckIn> _checkIns = {};
  double currentWeight = 58.5;
  double previousWeight = 59.2;

  // --- Free meals state ---
  final List<FreeMealEntry> _freeMeals = [
    FreeMealEntry(day: 'Domingo', description: 'Pizza com a família'),
  ];

  // --- "Chutei o balde" entries ---
  final List<CheatEntry> _cheatEntries = [];

  // --- Extra activities state ---
  final List<ExtraActivity> _extraActivities = [];

  // --- Saving state ---
  bool _saving = false;
  String? _error;
  bool get saving => _saving;
  String? get error => _error;

  RotinaViewModel({ApiClient? apiClient}) {
    final client = apiClient ?? ApiClient(TokenService());
    _workoutRepo = ApiWorkoutRepository(client);
    _dietRepo = ApiDietRepository(client);
    _activityRepo = ApiActivityRepository(client);
    _workoutPlanRepo = ApiWorkoutPlanRepository(client);
    _dietPlanRepo = ApiDietPlanRepository(client);
    loadData();
  }

  /// Fetches workout plan, diet plan, and last week results from the API.
  Future<void> loadData() async {
    _isLoading = true;
    _isEmpty = false;
    notifyListeners();

    try {
      // Fetch workout plan, diet plan, and latest workouts in parallel
      final results = await Future.wait([
        _workoutPlanRepo.getWorkoutPlans(),
        _dietPlanRepo.getDietPlans(),
        _workoutRepo.getLatestWorkouts(),
      ]);

      final workoutPlans = results[0];
      final dietPlans = results[1];
      final latestWorkouts = results[2];

      // Parse workout plan — pick today's workout day
      final List<WorkoutDay> days = _parseWorkoutDays(workoutPlans);
      final List<DietMeal> meals = _parseDietMeals(dietPlans);

      if (days.isEmpty && meals.isEmpty) {
        _isEmpty = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Pick today's workout day based on weekday name
      _day = _pickTodaysWorkout(days);
      _dietPlan = meals;
      _lastWeekResults = _parseLastWeekResults(latestWorkouts);

      // Initialize training state from API data
      if (_day != null) {
        for (final ex in _day!.exercises) {
          _confirmed[ex.id] = true;
          final last = _lastWeekResults[ex.id] ?? [];
          _sets[ex.id] = List.generate(ex.targetSets, (i) {
            final lastSet = i < last.length ? last[i] : null;
            final weight = lastSet != null
                ? lastSet.weight + 2.5
                : ex.targetWeight;
            final reps =
                lastSet?.reps ?? int.parse(ex.targetReps.split('-')[0]);
            return SetInput(weight: weight, reps: reps);
          });
        }
      }

      // Initialize diet check-ins
      for (final m in _dietPlan) {
        _checkIns[m.id] = MealCheckIn(mealId: m.id, status: MealStatus.seguiu);
      }

      _isLoading = false;
      notifyListeners();

      // Load activities in background
      _loadActivitiesFromApi();
    } catch (_) {
      _isLoading = false;
      _isEmpty = true;
      notifyListeners();
    }
  }

  List<WorkoutDay> _parseWorkoutDays(List<dynamic> workoutPlans) {
    if (workoutPlans.isEmpty) return [];
    // Use the first (most recent) workout plan
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

  List<DietMeal> _parseDietMeals(List<dynamic> dietPlans) {
    if (dietPlans.isEmpty) return [];
    // Use the first (most recent) diet plan
    final plan = dietPlans[0] as Map<String, dynamic>;
    final mealsJson = plan['meals'] as List<dynamic>? ?? [];
    return mealsJson.map((m) {
      final mealMap = m as Map<String, dynamic>;
      return DietMeal(
        id: mealMap['id'] ?? '',
        name: mealMap['name'] ?? '',
        time: mealMap['time'] ?? '',
        description: mealMap['description'] ?? '',
        kcal: mealMap['kcal'] ?? 0,
      );
    }).toList();
  }

  Map<String, List<ExerciseSet>> _parseLastWeekResults(
    List<dynamic> latestWorkouts,
  ) {
    final results = <String, List<ExerciseSet>>{};
    for (final log in latestWorkouts) {
      final logMap = log as Map<String, dynamic>;
      final exercises = logMap['exercises'] as List<dynamic>? ?? [];
      for (final ex in exercises) {
        final exMap = ex as Map<String, dynamic>;
        final exerciseId = exMap['exerciseId'] as String? ?? '';
        if (exerciseId.isEmpty) continue;
        // Only keep the first (most recent) result per exercise
        if (results.containsKey(exerciseId)) continue;
        final setsJson = exMap['sets'] as List<dynamic>? ?? [];
        results[exerciseId] = setsJson.map((s) {
          final sMap = s as Map<String, dynamic>;
          return ExerciseSet(
            reps: sMap['reps'] ?? 0,
            weight: (sMap['weight'] ?? 0).toDouble(),
          );
        }).toList();
      }
    }
    return results;
  }

  WorkoutDay? _pickTodaysWorkout(List<WorkoutDay> days) {
    if (days.isEmpty) return null;
    final weekdayNames = {
      1: 'Segunda',
      2: 'Terça',
      3: 'Quarta',
      4: 'Quinta',
      5: 'Sexta',
      6: 'Sábado',
      7: 'Domingo',
    };
    final todayName = weekdayNames[DateTime.now().weekday] ?? '';
    // Try to find a workout for today's weekday
    for (final d in days) {
      if (d.day.toLowerCase() == todayName.toLowerCase()) return d;
    }
    // Fallback: return the first day
    return days.first;
  }

  Future<void> _loadActivitiesFromApi() async {
    try {
      final data = await _activityRepo.getActivitiesForDay(DateTime.now());
      _extraActivities.clear();
      for (final item in data) {
        _extraActivities.add(
          ExtraActivity(
            id: item['_id'] ?? item['id'] ?? '',
            type: ActivityType.values.byName(item['type']),
            durationMinutes: item['durationMinutes'],
            source: ActivitySource.values.byName(item['source'] ?? 'manual'),
            date: DateTime.parse(item['date']),
          ),
        );
      }
      notifyListeners();
    } catch (_) {
      // Fallback: keep empty list
    }
  }

  // --- Training methods ---

  bool isConfirmed(String exId) => _confirmed[exId] ?? true;

  List<ExerciseSet> setsFor(String exId) => (_sets[exId] ?? [])
      .map((s) => ExerciseSet(reps: s.reps, weight: s.weight))
      .toList();

  void toggleExerciseConfirmed(String exId) {
    _confirmed[exId] = !(_confirmed[exId] ?? true);
    notifyListeners();
  }

  String lastWeekSummary(String exId) {
    final last = _lastWeekResults[exId];
    if (last == null || last.isEmpty) return 'Sem registro';
    final maxReps = last.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
    final maxWeight = last.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    return '${last.length}×$maxReps×${maxWeight}kg';
  }

  bool isProgressed(String exId, int setIndex) {
    final last = _lastWeekResults[exId];
    if (last == null || setIndex >= last.length) return false;
    final current = _sets[exId]?[setIndex];
    if (current == null) return false;
    return current.weight > last[setIndex].weight;
  }

  // --- Diet methods ---

  MealCheckIn checkInFor(String mealId) =>
      _checkIns[mealId] ??
      MealCheckIn(mealId: mealId, status: MealStatus.seguiu);

  void setMealStatus(String mealId, MealStatus status) {
    _checkIns[mealId] =
        (_checkIns[mealId] ?? MealCheckIn(mealId: mealId, status: status))
            .copyWith(status: status);
    notifyListeners();
  }

  void setMealNote(String mealId, String note) {
    _checkIns[mealId] =
        (_checkIns[mealId] ??
                MealCheckIn(mealId: mealId, status: MealStatus.ajustou))
            .copyWith(note: note);
    notifyListeners();
  }

  double get weightDelta => currentWeight - previousWeight;

  // --- Free meals methods ---

  List<FreeMealEntry> get freeMeals => List.unmodifiable(_freeMeals);

  void addFreeMeal() {
    _freeMeals.add(FreeMealEntry(day: '', description: ''));
    notifyListeners();
  }

  void updateFreeMealDay(int index, String day) {
    if (index < _freeMeals.length) {
      _freeMeals[index] = _freeMeals[index].copyWith(day: day);
      notifyListeners();
    }
  }

  void updateFreeMealDesc(int index, String desc) {
    if (index < _freeMeals.length) {
      _freeMeals[index] = _freeMeals[index].copyWith(description: desc);
      notifyListeners();
    }
  }

  void removeFreeMeal(int index) {
    if (index < _freeMeals.length && _freeMeals.length > 1) {
      _freeMeals.removeAt(index);
      notifyListeners();
    }
  }

  // --- Cheat entries methods ---

  List<CheatEntry> get cheatEntries => List.unmodifiable(_cheatEntries);

  void addCheatEntry() {
    _cheatEntries.add(CheatEntry(description: ''));
    notifyListeners();
  }

  void updateCheatEntry(int index, String description) {
    if (index < _cheatEntries.length) {
      _cheatEntries[index] = CheatEntry(description: description);
      notifyListeners();
    }
  }

  void removeCheatEntry(int index) {
    if (index < _cheatEntries.length) {
      _cheatEntries.removeAt(index);
      notifyListeners();
    }
  }

  // --- Extra activities methods ---

  List<ExtraActivity> get extraActivities =>
      List.unmodifiable(_extraActivities);

  void addExtraActivity(ExtraActivity activity) {
    _extraActivities.add(activity);
    notifyListeners();
    // Save to API in background
    _activityRepo.saveActivity(
      type: activity.type.name,
      durationMinutes: activity.durationMinutes,
      source: activity.source.name,
      date: activity.date,
    );
  }

  void removeExtraActivity(String activityId) {
    _extraActivities.removeWhere((a) => a.id == activityId);
    notifyListeners();
    _activityRepo.deleteActivity(activityId);
  }

  // --- Save full session to API ---

  Future<void> saveSession() async {
    if (_day == null) return;
    _saving = true;
    _error = null;
    notifyListeners();

    try {
      // Save workout
      await _workoutRepo.saveWorkout(
        date: DateTime.now(),
        workoutDayId: _day!.id,
        workoutName: _day!.name,
        focus: _day!.focus,
        exercises: _day!.exercises.map((ex) {
          final sets = setsFor(ex.id);
          return {
            'exerciseId': ex.id,
            'exerciseName': ex.name,
            'sets': sets
                .map((s) => {'reps': s.reps, 'weight': s.weight})
                .toList(),
            'confirmed': isConfirmed(ex.id),
          };
        }).toList(),
      );

      // Save diet
      await _dietRepo.saveDietLog(
        date: DateTime.now(),
        checkIns: _checkIns.values
            .map(
              (c) => {
                'mealId': c.mealId,
                'status': c.status.name,
                'note': c.note ?? '',
              },
            )
            .toList(),
        freeMeals: _freeMeals
            .map((f) => {'day': f.day, 'description': f.description})
            .toList(),
        cheatEntries: _cheatEntries
            .map((c) => {'description': c.description})
            .toList(),
      );

      _saving = false;
      notifyListeners();
    } catch (e) {
      _saving = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Computed ---

  bool get isDailyRoutineComplete {
    if (_day == null) return false;
    final allExercisesConfirmed = _day!.exercises.every(
      (ex) => _confirmed[ex.id] == true,
    );
    final allMealsChecked = _dietPlan.every(
      (meal) => _checkIns.containsKey(meal.id),
    );
    return allExercisesConfirmed && allMealsChecked;
  }
}

class SetInput {
  final double weight;
  final int reps;
  SetInput({required this.weight, required this.reps});
}

class FreeMealEntry {
  final String day;
  final String description;
  const FreeMealEntry({required this.day, required this.description});

  FreeMealEntry copyWith({String? day, String? description}) => FreeMealEntry(
    day: day ?? this.day,
    description: description ?? this.description,
  );
}

class CheatEntry {
  final String description;
  const CheatEntry({required this.description});
}
