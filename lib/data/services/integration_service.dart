import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart' as mock;

/// Handles external integrations (Garmin, Apple Health, Google Fit).
/// Currently returns mock data — plug real SDKs later.
class IntegrationService {
  List<IntegrationAccount> getAccounts() => mock.integrations;

  Future<bool> connect(String accountId) async {
    // TODO: implement real OAuth / SDK connection
    return false;
  }

  Future<void> disconnect(String accountId) async {
    // TODO: implement
  }

  /// Compares synced exercises from Garmin against the ficha de treino.
  /// Returns a list of [SyncedExercise] with [ExerciseMatchStatus.mapeado]
  /// if the exercise name matches one in the ficha, or
  /// [ExerciseMatchStatus.naoMapeado] otherwise.
  List<SyncedExercise> matchExercisesAgainstFicha(
    GarminSyncResult syncResult,
    List<Exercise> ficha,
  ) {
    return syncResult.exercises.map((synced) {
      final match = ficha.cast<Exercise?>().firstWhere(
        (e) => e!.name.toLowerCase() == synced.name.toLowerCase(),
        orElse: () => null,
      );

      if (match != null) {
        return SyncedExercise(
          name: synced.name,
          sets: synced.sets,
          matchStatus: ExerciseMatchStatus.mapeado,
          matchedExerciseId: match.id,
        );
      }

      return SyncedExercise(
        name: synced.name,
        sets: synced.sets,
        matchStatus: ExerciseMatchStatus.naoMapeado,
      );
    }).toList();
  }

  /// Returns true if every synced exercise has been validated (status mapeado).
  /// This determines whether the confirmation button should be enabled.
  bool areAllExercisesValidated(List<SyncedExercise> exercises) {
    if (exercises.isEmpty) return false;
    return exercises.every((e) => e.matchStatus == ExerciseMatchStatus.mapeado);
  }

  /// Checks if the Garmin integration is currently connected.
  /// When disconnected, the app should fall back to full manual entry.
  bool isGarminConnected() {
    final accounts = getAccounts();
    final garmin = accounts.cast<IntegrationAccount?>().firstWhere(
      (a) => a!.id == 'garmin',
      orElse: () => null,
    );
    return garmin?.status == IntegrationStatus.connected;
  }
}
