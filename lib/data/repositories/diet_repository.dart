import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart' as mock;

/// Abstraction for diet data access.
class DietRepository {
  List<DietMeal> getDietPlan() => mock.dietPlan;

  Future<void> saveMealCheckIn(MealCheckIn checkIn) async {
    // TODO: persist
  }
}
