import 'package:flutter/material.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart';
import 'package:oi_coach/data/repositories/api_activity_repository.dart';
import 'package:oi_coach/data/repositories/api_diet_repository.dart';
import 'package:oi_coach/data/repositories/api_workout_repository.dart';

class RotinaViewModel extends ChangeNotifier {
  final _workoutRepo = ApiWorkoutRepository();
  final _dietRepo = ApiDietRepository();
  final _activityRepo = ApiActivityRepository();

  // --- Training state ---
  final WorkoutDay day = workoutPlan[2]; // Treino C demo
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

  RotinaViewModel() {
    for (final ex in day.exercises) {
      _confirmed[ex.id] = true;
      final last = lastWeekResults[ex.id] ?? [];
      _sets[ex.id] = List.generate(ex.targetSets, (i) {
        final lastSet = i < last.length ? last[i] : null;
        final weight = lastSet != null ? lastSet.weight + 2.5 : ex.targetWeight;
        final reps = lastSet?.reps ?? int.parse(ex.targetReps.split('-')[0]);
        return SetInput(weight: weight, reps: reps);
      });
    }
    for (final m in dietPlan) {
      _checkIns[m.id] = MealCheckIn(mealId: m.id, status: MealStatus.seguiu);
    }
    _loadActivitiesFromApi();
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
    final last = lastWeekResults[exId];
    if (last == null || last.isEmpty) return 'Sem registro';
    final maxReps = last.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
    final maxWeight = last.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    return '${last.length}×$maxReps×${maxWeight}kg';
  }

  bool isProgressed(String exId, int setIndex) {
    final last = lastWeekResults[exId];
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
    _saving = true;
    _error = null;
    notifyListeners();

    try {
      // Save workout
      await _workoutRepo.saveWorkout(
        date: DateTime.now(),
        workoutDayId: day.id,
        workoutName: day.name,
        focus: day.focus,
        exercises: day.exercises.map((ex) {
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
    final allExercisesConfirmed = day.exercises.every(
      (ex) => _confirmed[ex.id] == true,
    );
    final allMealsChecked = dietPlan.every(
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
