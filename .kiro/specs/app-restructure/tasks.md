# Implementation Plan: app-restructure

## Overview

Reestruturação incremental do app Flutter "Apex.OS — Terminal de Desempenho" (oi_coach): corrigir safe areas, simplificar navegação de 7→4 abas, unificar treino+dieta em RotinaView, adicionar atividades extras, input de peso no relatório, expandir progresso para carga+reps, mover Relatório/Fichas para sub-routes do dashboard, e validar com property-based tests (glados).

## Tasks

- [ ] 1. Create SafePage widget and apply to all screens
  - [x] 1.1 Create `lib/shared/widgets/safe_page.dart` with SafeArea + EdgeInsets.all(16) wrapper
    - Implement `SafePage` StatelessWidget with `child` and optional `padding` parameters
    - Export from `lib/shared/widgets/widgets.dart`
    - _Requirements: 1.1, 1.4_

  - [x] 1.2 Wrap all existing views with SafePage
    - Replace `padding: EdgeInsets.all(24)` in DashboardView, ProgressoView, RelatorioView, TreinoView, DietaView, FichasView, ConfiguracoesView with SafePage wrapper
    - Ensure text uses `TextOverflow.ellipsis` or `softWrap: true` where appropriate
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ] 2. Update navigation from 7 tabs to 4 and restructure router
  - [x] 2.1 Update `lib/shared/widgets/app_shell.dart` to 4 tabs
    - Change `_tabs` to: Hoje (/), Rotina (/rotina), Progresso (/progresso), Config (/configuracoes)
    - Update icons: home_outlined, calendar_today_outlined, trending_up, settings_outlined
    - Ensure labels render without overflow on 320dp+ screens
    - _Requirements: 2.1, 2.6_

  - [x] 2.2 Update `lib/app/router.dart` to new route structure
    - Remove standalone /fichas, /treino, /dieta, /relatorio routes
    - Add /rotina route pointing to RotinaView
    - Add /relatorio and /fichas as sub-routes of `/` (children of dashboard route)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 8.3, 8.4, 8.5_

  - [x] 2.3 Update DashboardView with Relatório and Fichas navigation cards
    - Keep existing metric cards row
    - Add navigation cards for Relatório and Fichas that use `context.go('/relatorio')` and `context.go('/fichas')`
    - Remove the old Progresso nav card (now a tab)
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [x] 2.4 Add back navigation from Relatório and Fichas sub-pages
    - Ensure AppBar or back button navigates to dashboard
    - Bottom nav should show "Hoje" tab as active on sub-pages
    - _Requirements: 8.5_

- [ ] 3. Create new data models
  - [x] 3.1 Create `lib/core/models/extra_activity.dart`
    - Define `ActivityType` enum (yoga, corrida, crossfit, natacao, tenisDeMesa)
    - Define `ActivitySource` enum (manual, garmin)
    - Define `ExtraActivity` class with id, type, durationMinutes, source, date
    - _Requirements: 4.2, 4.3, 4.4, 4.5_

  - [x] 3.2 Create `lib/core/models/progress_entry.dart` with ExerciseProgressEntry
    - Define `ExerciseProgressEntry` with exerciseId, exerciseName, previousWeight, previousReps, currentWeight, currentReps
    - Implement `weightDelta`, `repsDelta`, `hasProgression`, `hasRegression` getters
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [x] 3.3 Create GarminSyncResult and SyncedExercise models in `lib/core/models/integration.dart`
    - Add `ExerciseMatchStatus` enum (mapeado, naoMapeado)
    - Add `GarminSyncResult` class with sessionId, date, exercises
    - Add `SyncedExercise` class with name, sets, matchStatus, matchedExerciseId
    - _Requirements: 6.1, 6.2_

  - [x] 3.4 Update `lib/core/models/models.dart` barrel file to export new models
    - Export extra_activity.dart, progress_entry.dart
    - _Requirements: 3.1, 7.1_

- [ ] 4. Create new repositories
  - [x] 4.1 Create `lib/data/repositories/weight_repository.dart`
    - Implement `WeightRepository` with loadWeight(), saveWeight(double kg), loadPreviousWeight()
    - Use SharedPreferences for persistence
    - Add `WeightValidator` with static validate() method (range 30–300 kg)
    - _Requirements: 5.2, 5.4, 5.5_

  - [x] 4.2 Create `lib/data/repositories/activity_repository.dart`
    - Implement `ActivityRepository` with getActivitiesForDay(DateTime), saveActivity(ExtraActivity), deleteActivity(String id)
    - Add `ActivityValidator` with validateDuration() method
    - Use SharedPreferences for persistence (JSON-encoded list)
    - _Requirements: 4.2, 4.3, 4.6_

- [x] 5. Checkpoint — Ensure models and repositories compile
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Create unified RotinaView (treino + dieta + atividades extras)
  - [x] 6.1 Create `lib/features/rotina/view_model/rotina_view_model.dart`
    - Extend ChangeNotifier, combine TreinoViewModel + DietaViewModel logic
    - Add extra activities state (list of ExtraActivity)
    - Implement `isDailyRoutineComplete` getter (all exercises confirmed AND all meals checked)
    - Implement addExtraActivity(), removeExtraActivity()
    - _Requirements: 3.1, 3.3, 3.4, 3.5, 4.6_

  - [x] 6.2 Create `lib/features/rotina/view/rotina_view.dart`
    - Single scrollable ListView with sections: training first, diet second, extra activities third
    - Training section: exercise cards with sets, weight input, reps input, mapping confirmation (reuse TreinoView patterns)
    - Diet section: meal check-ins with status chips (Seguiu/Ajustou/Não), notes, free meal, fasting weight display (reuse DietaView patterns)
    - Extra activities section: list of ActivityLogCard + "Adicionar atividade" button
    - Show completion indicator when isDailyRoutineComplete is true
    - Wrap with SafePage
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.6_

  - [x] 6.3 Create `lib/shared/widgets/activity_log_card.dart`
    - Display activity type, duration in minutes, source badge ("Manual" or "Garmin")
    - _Requirements: 4.4, 4.5_

  - [x] 6.4 Create `lib/shared/widgets/add_activity_sheet.dart`
    - Bottom sheet with dropdown for activity type selection (yoga, corrida, crossfit, natação, tênis de mesa)
    - Duration input field in minutes
    - Save button (disabled until type selected and duration > 0)
    - _Requirements: 4.2, 4.3_

- [ ] 7. Update ProgressoView for carga + reps
  - [x] 7.1 Refactor `lib/features/progresso/view/progresso_view.dart`
    - Add "REPS" column to the comparison table alongside existing weight columns
    - Display weight delta (kg) and reps delta per exercise
    - Color indicators: green if weightDelta > 0 OR repsDelta > 0, red if both < 0
    - Update summary stats: count of exercises with weight progression + count with reps progression
    - Use ExerciseProgressEntry model for data
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [ ] 8. Add weight input to RelatorioView
  - [x] 8.1 Update `lib/features/relatorio/view/relatorio_view.dart`
    - Add editable weight input field (TextFormField) showing current fasting weight in kg
    - On submit: validate with WeightValidator, save via WeightRepository, recalculate and display delta
    - Show validation error message if weight outside [30, 300] range
    - Include logged extra activities in the weekly summary text
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 4.7_

- [ ] 9. Update IntegrationService for Garmin sync flow
  - [x] 9.1 Expand `lib/data/services/integration_service.dart`
    - Add method to compare synced exercises against ficha de treino
    - Return match status (mapeado/naoMapeado) per exercise
    - Add method to check if all exercises are validated (enables confirmation button)
    - Support fallback to full manual entry when Garmin disconnected
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [x] 10. Checkpoint — Ensure app compiles and all views render
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Remove deprecated features and clean up
  - [x] 11.1 Remove `lib/features/treino/` and `lib/features/dieta/` directories
    - These are replaced by `lib/features/rotina/`
    - Remove any remaining imports referencing old paths
    - _Requirements: 2.1, 3.1_

  - [x] 11.2 Update `lib/data/mock_data.dart` with new mock data
    - Add mock ExtraActivity entries
    - Add mock ExerciseProgressEntry data with reps
    - Update weeklySummary to include extraActivities field
    - _Requirements: 4.6, 7.1_

- [ ] 12. Add glados dependency and write property-based tests
  - [x] 12.1 Add `glados: ^1.1.1` to dev_dependencies in `pubspec.yaml`
    - Run `flutter pub get` to install
    - _Requirements: Testing Strategy_

  - [ ]* 12.2 Write property test for daily routine completion indicator
    - **Property 1: Daily routine completion indicator**
    - For any combination of exercise confirmation states and meal check-in states, isDailyRoutineComplete == true iff all exercises confirmed AND all meals have status set
    - **Validates: Requirements 3.3**

  - [ ]* 12.3 Write property test for activity input validation
    - **Property 2: Activity input validation**
    - For any string, accepted iff it's one of the 5 valid ActivityType values; for any int duration, accepted iff > 0
    - **Validates: Requirements 4.2, 4.3**

  - [ ]* 12.4 Write property test for activity source badge rendering
    - **Property 3: Activity source badge rendering**
    - For any ExtraActivity, badge text == "Garmin" when source is garmin, "Manual" when source is manual
    - **Validates: Requirements 4.4, 4.5**

  - [ ]* 12.5 Write property test for multiple activities per day
    - **Property 4: Multiple activities per day**
    - For any non-negative N, adding N activities results in exactly N entries in the day's list
    - **Validates: Requirements 4.6**

  - [ ]* 12.6 Write property test for weight persistence round-trip
    - **Property 5: Weight persistence round-trip**
    - For any valid weight in [30, 300], save then load returns same value
    - Use `SharedPreferences.setMockInitialValues({})` for test setup
    - **Validates: Requirements 5.2, 5.4**

  - [ ]* 12.7 Write property test for weight delta calculation
    - **Property 6: Weight delta calculation**
    - For any two doubles (current, previous), delta == current - previous
    - **Validates: Requirements 5.3**

  - [ ]* 12.8 Write property test for weight validation range
    - **Property 7: Weight validation range**
    - For any double, validator returns null iff value in [30, 300], error message otherwise
    - **Validates: Requirements 5.5**

  - [ ]* 12.9 Write property test for exercise-ficha matching
    - **Property 8: Exercise-ficha matching**
    - For any exercise name and ficha list, match returns mapeado iff name exists in ficha
    - **Validates: Requirements 6.2, 6.5**

  - [ ]* 12.10 Write property test for confirmation enabled state
    - **Property 9: Confirmation enabled iff all exercises validated**
    - For any list of SyncedExercise with match statuses, confirmation enabled iff all are mapeado
    - **Validates: Requirements 6.3**

  - [ ]* 12.11 Write property test for progress delta calculation
    - **Property 10: Progress delta calculation**
    - For any ExerciseProgressEntry, weightDelta == currentWeight - previousWeight, repsDelta == currentReps - previousReps
    - **Validates: Requirements 7.2, 7.3**

  - [ ]* 12.12 Write property test for progression indicator classification
    - **Property 11: Progression indicator classification**
    - For any ExerciseProgressEntry, hasProgression == (weightDelta > 0 || repsDelta > 0), hasRegression == (weightDelta < 0 && repsDelta < 0)
    - **Validates: Requirements 7.4, 7.5**

  - [ ]* 12.13 Write property test for summary progression counts
    - **Property 12: Summary progression counts**
    - For any list of ExerciseProgressEntry, weight progression count == entries where weightDelta > 0, reps count == entries where repsDelta > 0
    - **Validates: Requirements 7.6**

- [ ] 13. Write unit tests for navigation, layout, and structural verification
  - [ ]* 13.1 Write unit tests for navigation structure
    - Verify router has exactly 4 shell routes (/, /rotina, /progresso, /configuracoes)
    - Verify /relatorio and /fichas are sub-routes of /
    - Verify AppShell renders exactly 4 tabs with correct labels
    - _Requirements: 2.1, 8.3, 8.4_

  - [ ]* 13.2 Write widget tests for SafePage and layout
    - Verify SafePage wraps content in SafeArea
    - Verify default padding of 16dp
    - Verify bottom nav labels don't overflow at 320dp width
    - _Requirements: 1.1, 1.4, 2.6_

  - [ ]* 13.3 Write unit tests for RotinaView structure
    - Verify training section appears before diet section in the ListView
    - Verify extra activities section is present below diet
    - Verify completion indicator shows when all exercises confirmed + all meals checked
    - _Requirements: 3.1, 3.2, 3.3, 4.1_

  - [ ]* 13.4 Write unit tests for dashboard cards and Garmin fallback
    - Verify dashboard has Relatório and Fichas navigation cards
    - Verify manual entry is available when Garmin is disconnected
    - Verify RelatorioView has editable weight input field
    - _Requirements: 6.6, 8.1, 8.2, 5.1_

- [x] 14. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The app uses Dart/Flutter — all code examples and implementations use this language
- `glados` is the PBT library for Dart; use `SharedPreferences.setMockInitialValues({})` for persistence tests
