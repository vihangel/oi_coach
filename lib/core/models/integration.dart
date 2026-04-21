import 'exercise.dart';

enum IntegrationStatus { connected, disconnected }

class IntegrationAccount {
  final String id;
  final String name;
  final String description;
  final IntegrationStatus status;

  const IntegrationAccount({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  IntegrationAccount copyWith({IntegrationStatus? status}) {
    return IntegrationAccount(
      id: id,
      name: name,
      description: description,
      status: status ?? this.status,
    );
  }
}

enum ExerciseMatchStatus { mapeado, naoMapeado }

class GarminSyncResult {
  final String sessionId;
  final DateTime date;
  final List<SyncedExercise> exercises;

  const GarminSyncResult({
    required this.sessionId,
    required this.date,
    required this.exercises,
  });
}

class SyncedExercise {
  final String name;
  final List<ExerciseSet> sets;
  final ExerciseMatchStatus matchStatus;
  final String? matchedExerciseId;

  const SyncedExercise({
    required this.name,
    required this.sets,
    required this.matchStatus,
    this.matchedExerciseId,
  });
}
