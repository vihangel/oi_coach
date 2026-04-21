import 'package:flutter/material.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart';

class RotinaViewModel extends ChangeNotifier {
  // --- Training state ---
  final WorkoutDay day = workoutPlan[2]; // Treino C demo

  final Map<String, bool> _confirmed = {};
  final Map<String, List<_SetInput>> _sets = {};

  // --- Diet state ---
  final Map<String, MealCheckIn> _checkIns = {};

  String freeMealDay = 'Domingo';
  String freeMealDesc = 'Pizza com a família';
  double currentWeight = 58.5;
  double previousWeight = 59.2;

  // --- Free meals state (multiple allowed) ---
  final List<_FreeMealEntry> _freeMeals = [
    _FreeMealEntry(day: 'Domingo', description: 'Pizza com a família'),
  ];

  // --- "Chutei o balde" entries ---
  final List<_CheatEntry> _cheatEntries = [];

  // --- Extra activities state ---
  final List<ExtraActivity> _extraActivities = [];

  RotinaViewModel() {
    // Initialize training state
    for (final ex in day.exercises) {
      _confirmed[ex.id] = true;
      final last = lastWeekResults[ex.id] ?? [];
      _sets[ex.id] = List.generate(ex.targetSets, (i) {
        final lastSet = i < last.length ? last[i] : null;
        final weight = lastSet != null ? lastSet.weight + 2.5 : ex.targetWeight;
        final reps = lastSet?.reps ?? int.parse(ex.targetReps.split('-')[0]);
        return _SetInput(weight: weight, reps: reps);
      });
    }

    // Initialize diet state
    for (final m in dietPlan) {
      _checkIns[m.id] = MealCheckIn(mealId: m.id, status: MealStatus.seguiu);
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

  List<_FreeMealEntry> get freeMeals => List.unmodifiable(_freeMeals);

  void addFreeMeal() {
    _freeMeals.add(_FreeMealEntry(day: '', description: ''));
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

  List<_CheatEntry> get cheatEntries => List.unmodifiable(_cheatEntries);

  void addCheatEntry() {
    _cheatEntries.add(_CheatEntry(description: ''));
    notifyListeners();
  }

  void updateCheatEntry(int index, String description) {
    if (index < _cheatEntries.length) {
      _cheatEntries[index] = _CheatEntry(description: description);
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
  }

  void removeExtraActivity(String activityId) {
    _extraActivities.removeWhere((a) => a.id == activityId);
    notifyListeners();
  }

  // --- Computed: daily routine completion ---

  /// Returns true when all exercises are confirmed AND all meals have a check-in.
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

class _SetInput {
  final double weight;
  final int reps;
  _SetInput({required this.weight, required this.reps});
}

class _FreeMealEntry {
  final String day;
  final String description;
  const _FreeMealEntry({required this.day, required this.description});

  _FreeMealEntry copyWith({String? day, String? description}) => _FreeMealEntry(
    day: day ?? this.day,
    description: description ?? this.description,
  );
}

class _CheatEntry {
  final String description;
  const _CheatEntry({required this.description});
}
