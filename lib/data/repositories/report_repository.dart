import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart' as mock;

/// Abstraction for weekly report data.
class ReportRepository {
  WeeklyReport getWeeklySummary() => mock.weeklySummary;
}
