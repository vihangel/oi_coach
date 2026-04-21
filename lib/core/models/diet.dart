class DietMeal {
  final String id;
  final String name;
  final String time;
  final String description;
  final int kcal;

  const DietMeal({
    required this.id,
    required this.name,
    required this.time,
    required this.description,
    required this.kcal,
  });
}

enum MealStatus { seguiu, ajustou, nao }

class MealCheckIn {
  final String mealId;
  final MealStatus status;
  final String? note;

  const MealCheckIn({required this.mealId, required this.status, this.note});

  MealCheckIn copyWith({MealStatus? status, String? note}) {
    return MealCheckIn(
      mealId: mealId,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
