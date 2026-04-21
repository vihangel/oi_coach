import 'package:oi_coach/core/models/extra_activity.dart';

class WeeklyReport {
  final double weightFasted;
  final int trainingsDone;
  final int trainingsPlanned;
  final int dietAdherence;
  final FreeMeal freeMeal;
  final List<ProgressEntry> progress;
  final List<ExtraActivity> extraActivities;

  const WeeklyReport({
    required this.weightFasted,
    required this.trainingsDone,
    required this.trainingsPlanned,
    required this.dietAdherence,
    required this.freeMeal,
    required this.progress,
    this.extraActivities = const [],
  });
}

class FreeMeal {
  final String day;
  final String description;

  const FreeMeal({required this.day, required this.description});
}

class ProgressEntry {
  final String exercise;
  final String from;
  final String to;
  final bool improved;

  const ProgressEntry({
    required this.exercise,
    required this.from,
    required this.to,
    required this.improved,
  });
}
