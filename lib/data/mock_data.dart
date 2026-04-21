import 'package:oi_coach/core/models/models.dart';

const workoutPlan = <WorkoutDay>[
  WorkoutDay(
    id: 'a',
    name: 'Treino A',
    focus: 'Peito + Tríceps',
    day: 'Segunda',
    exercises: [
      Exercise(
        id: 'a1',
        order: 1,
        name: 'Supino reto barra',
        targetSets: 4,
        targetReps: '8-10',
        targetWeight: 60,
      ),
      Exercise(
        id: 'a2',
        order: 2,
        name: 'Supino inclinado halteres',
        targetSets: 3,
        targetReps: '10',
        targetWeight: 22,
      ),
      Exercise(
        id: 'a3',
        order: 3,
        name: 'Crucifixo máquina',
        targetSets: 3,
        targetReps: '12',
        targetWeight: 35,
      ),
      Exercise(
        id: 'a4',
        order: 4,
        name: 'Tríceps corda',
        targetSets: 4,
        targetReps: '12',
        targetWeight: 25,
      ),
    ],
  ),
  WorkoutDay(
    id: 'b',
    name: 'Treino B',
    focus: 'Costas + Bíceps',
    day: 'Quarta',
    exercises: [
      Exercise(
        id: 'b1',
        order: 1,
        name: 'Puxada frente',
        targetSets: 4,
        targetReps: '10',
        targetWeight: 55,
      ),
      Exercise(
        id: 'b2',
        order: 2,
        name: 'Remada curvada',
        targetSets: 4,
        targetReps: '8',
        targetWeight: 50,
      ),
      Exercise(
        id: 'b3',
        order: 3,
        name: 'Rosca direta',
        targetSets: 3,
        targetReps: '12',
        targetWeight: 14,
      ),
    ],
  ),
  WorkoutDay(
    id: 'c',
    name: 'Treino C',
    focus: 'Pernas + Glúteos',
    day: 'Sexta',
    exercises: [
      Exercise(
        id: 'c1',
        order: 1,
        name: 'Agachamento livre',
        targetSets: 4,
        targetReps: '8',
        targetWeight: 65,
      ),
      Exercise(
        id: 'c2',
        order: 2,
        name: 'Leg press 45°',
        targetSets: 4,
        targetReps: '12',
        targetWeight: 180,
      ),
      Exercise(
        id: 'c3',
        order: 3,
        name: 'Cadeira extensora',
        targetSets: 3,
        targetReps: '15',
        targetWeight: 45,
      ),
      Exercise(
        id: 'c4',
        order: 4,
        name: 'Stiff',
        targetSets: 3,
        targetReps: '10',
        targetWeight: 50,
      ),
    ],
  ),
];

const dietPlan = <DietMeal>[
  DietMeal(
    id: 'm1',
    name: 'Café da manhã',
    time: '07:30',
    description: '3 ovos, 2 fatias de pão integral, 1 banana',
    kcal: 480,
  ),
  DietMeal(
    id: 'm2',
    name: 'Lanche da manhã',
    time: '10:30',
    description: 'Iogurte natural + granola + 30g whey',
    kcal: 320,
  ),
  DietMeal(
    id: 'm3',
    name: 'Almoço',
    time: '13:00',
    description: '150g frango, 100g arroz, salada, feijão',
    kcal: 720,
  ),
  DietMeal(
    id: 'm4',
    name: 'Pré-treino',
    time: '16:30',
    description: 'Pão integral + pasta de amendoim + café',
    kcal: 380,
  ),
  DietMeal(
    id: 'm5',
    name: 'Jantar',
    time: '20:00',
    description: '180g patinho moído, batata doce, brócolis',
    kcal: 640,
  ),
];

const lastWeekResults = <String, List<ExerciseSet>>{
  'a1': [
    ExerciseSet(reps: 8, weight: 57.5),
    ExerciseSet(reps: 8, weight: 57.5),
    ExerciseSet(reps: 7, weight: 57.5),
    ExerciseSet(reps: 6, weight: 57.5),
  ],
  'a2': [
    ExerciseSet(reps: 10, weight: 20),
    ExerciseSet(reps: 10, weight: 20),
    ExerciseSet(reps: 9, weight: 20),
  ],
  'a3': [
    ExerciseSet(reps: 12, weight: 32.5),
    ExerciseSet(reps: 12, weight: 32.5),
    ExerciseSet(reps: 10, weight: 32.5),
  ],
  'a4': [
    ExerciseSet(reps: 12, weight: 22.5),
    ExerciseSet(reps: 12, weight: 22.5),
    ExerciseSet(reps: 12, weight: 22.5),
    ExerciseSet(reps: 10, weight: 22.5),
  ],
  'c1': [
    ExerciseSet(reps: 8, weight: 60),
    ExerciseSet(reps: 8, weight: 60),
    ExerciseSet(reps: 7, weight: 60),
    ExerciseSet(reps: 6, weight: 60),
  ],
  'c2': [
    ExerciseSet(reps: 12, weight: 170),
    ExerciseSet(reps: 12, weight: 170),
    ExerciseSet(reps: 12, weight: 170),
    ExerciseSet(reps: 10, weight: 170),
  ],
  'c3': [
    ExerciseSet(reps: 15, weight: 40),
    ExerciseSet(reps: 15, weight: 40),
    ExerciseSet(reps: 13, weight: 40),
  ],
  'c4': [
    ExerciseSet(reps: 10, weight: 45),
    ExerciseSet(reps: 10, weight: 45),
    ExerciseSet(reps: 10, weight: 45),
  ],
  'b1': [
    ExerciseSet(reps: 10, weight: 50),
    ExerciseSet(reps: 10, weight: 50),
    ExerciseSet(reps: 9, weight: 50),
    ExerciseSet(reps: 8, weight: 50),
  ],
  'b2': [
    ExerciseSet(reps: 8, weight: 45),
    ExerciseSet(reps: 8, weight: 45),
    ExerciseSet(reps: 8, weight: 45),
    ExerciseSet(reps: 7, weight: 45),
  ],
  'b3': [
    ExerciseSet(reps: 12, weight: 12),
    ExerciseSet(reps: 12, weight: 12),
    ExerciseSet(reps: 11, weight: 12),
  ],
};

final weeklySummary = WeeklyReport(
  weightFasted: 58.5,
  trainingsDone: 3,
  trainingsPlanned: 3,
  dietAdherence: 92,
  freeMeal: FreeMeal(day: 'Domingo', description: 'Pizza com a família'),
  progress: [
    ProgressEntry(
      exercise: 'Agachamento livre',
      from: '60kg × 8',
      to: '65kg × 8',
      improved: true,
    ),
    ProgressEntry(
      exercise: 'Supino reto',
      from: '57.5kg × 8',
      to: '60kg × 8',
      improved: true,
    ),
    ProgressEntry(
      exercise: 'Puxada frente',
      from: '50kg × 10',
      to: '55kg × 10',
      improved: true,
    ),
  ],
  extraActivities: [
    ExtraActivity(
      id: 'ea1',
      type: ActivityType.yoga,
      durationMinutes: 45,
      source: ActivitySource.manual,
      date: DateTime(2024, 1, 15),
    ),
    ExtraActivity(
      id: 'ea2',
      type: ActivityType.corrida,
      durationMinutes: 30,
      source: ActivitySource.garmin,
      date: DateTime(2024, 1, 17),
    ),
  ],
);

final mockExtraActivities = <ExtraActivity>[
  ExtraActivity(
    id: 'ea1',
    type: ActivityType.yoga,
    durationMinutes: 45,
    source: ActivitySource.manual,
    date: DateTime.now(),
  ),
  ExtraActivity(
    id: 'ea2',
    type: ActivityType.corrida,
    durationMinutes: 30,
    source: ActivitySource.garmin,
    date: DateTime.now(),
  ),
  ExtraActivity(
    id: 'ea3',
    type: ActivityType.natacao,
    durationMinutes: 60,
    source: ActivitySource.manual,
    date: DateTime.now(),
  ),
];

const mockProgressEntries = <ExerciseProgressEntry>[
  ExerciseProgressEntry(
    exerciseId: 'a1',
    exerciseName: 'Supino reto barra',
    previousWeight: 57.5,
    previousReps: 8,
    currentWeight: 60,
    currentReps: 8,
  ),
  ExerciseProgressEntry(
    exerciseId: 'c1',
    exerciseName: 'Agachamento livre',
    previousWeight: 60,
    previousReps: 8,
    currentWeight: 65,
    currentReps: 8,
  ),
  ExerciseProgressEntry(
    exerciseId: 'b1',
    exerciseName: 'Puxada frente',
    previousWeight: 50,
    previousReps: 10,
    currentWeight: 55,
    currentReps: 10,
  ),
  ExerciseProgressEntry(
    exerciseId: 'a4',
    exerciseName: 'Tríceps corda',
    previousWeight: 25,
    previousReps: 12,
    currentWeight: 25,
    currentReps: 10,
  ),
];

const integrations = <IntegrationAccount>[
  IntegrationAccount(
    id: 'garmin',
    name: 'Garmin Connect',
    description:
        'Importe automaticamente séries, reps e cargas dos seus treinos registrados.',
    status: IntegrationStatus.disconnected,
  ),
  IntegrationAccount(
    id: 'apple_health',
    name: 'Apple Health',
    description: 'Sincronize peso e medidas corporais.',
    status: IntegrationStatus.disconnected,
  ),
  IntegrationAccount(
    id: 'google_fit',
    name: 'Google Fit',
    description: 'Backup automático do histórico de treino.',
    status: IntegrationStatus.disconnected,
  ),
];
