require('dotenv').config();
const mongoose = require('mongoose');

const User = require('./models/User');
const WorkoutPlan = require('./models/WorkoutPlan');
const DietPlan = require('./models/DietPlan');
const WorkoutLog = require('./models/Workout');
const DietLog = require('./models/Diet');
const Weight = require('./models/Weight');
const Activity = require('./models/Activity');

async function seed() {
  console.log('🌱 Connecting to MongoDB...');
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('✅ Connected');

  // 1. Find or create demo user
  let user = await User.findOne({ email: 'demo@apex.os' });
  if (!user) {
    user = await User.create({
      name: 'Atleta Demo',
      email: 'demo@apex.os',
      password: 'demo1234',
    });
    console.log('👤 Created demo user:', user.email);
  } else {
    console.log('👤 Using existing user:', user.email);
  }

  const userId = user._id;

  // 2. WorkoutPlan — Ficha ABC (matches original mock_data.dart)
  await WorkoutPlan.deleteMany({ userId });
  const workoutPlan = await WorkoutPlan.create({
    userId,
    name: 'Ficha ABC',
    days: [
      {
        id: 'a',
        name: 'Treino A',
        focus: 'Peito + Tríceps',
        day: 'Segunda',
        exercises: [
          { id: 'a1', order: 1, name: 'Supino reto barra', targetSets: 4, targetReps: '8-10', targetWeight: 60 },
          { id: 'a2', order: 2, name: 'Supino inclinado halteres', targetSets: 3, targetReps: '10', targetWeight: 22 },
          { id: 'a3', order: 3, name: 'Crucifixo máquina', targetSets: 3, targetReps: '12', targetWeight: 35 },
          { id: 'a4', order: 4, name: 'Tríceps corda', targetSets: 4, targetReps: '12', targetWeight: 25 },
        ],
      },
      {
        id: 'b',
        name: 'Treino B',
        focus: 'Costas + Bíceps',
        day: 'Quarta',
        exercises: [
          { id: 'b1', order: 1, name: 'Puxada frente', targetSets: 4, targetReps: '10', targetWeight: 55 },
          { id: 'b2', order: 2, name: 'Remada curvada', targetSets: 4, targetReps: '8', targetWeight: 50 },
          { id: 'b3', order: 3, name: 'Rosca direta', targetSets: 3, targetReps: '12', targetWeight: 14 },
        ],
      },
      {
        id: 'c',
        name: 'Treino C',
        focus: 'Pernas + Glúteos',
        day: 'Sexta',
        exercises: [
          { id: 'c1', order: 1, name: 'Agachamento livre', targetSets: 4, targetReps: '8', targetWeight: 65 },
          { id: 'c2', order: 2, name: 'Leg press 45°', targetSets: 4, targetReps: '12', targetWeight: 180 },
          { id: 'c3', order: 3, name: 'Cadeira extensora', targetSets: 3, targetReps: '15', targetWeight: 45 },
          { id: 'c4', order: 4, name: 'Stiff', targetSets: 3, targetReps: '10', targetWeight: 50 },
        ],
      },
    ],
  });
  console.log('🏋️ Created WorkoutPlan:', workoutPlan.name);

  // 3. DietPlan — matches original mock_data.dart
  await DietPlan.deleteMany({ userId });
  const dietPlan = await DietPlan.create({
    userId,
    name: 'Plano Cutting',
    meals: [
      { id: 'm1', name: 'Café da manhã', time: '07:30', description: '3 ovos, 2 fatias de pão integral, 1 banana', kcal: 480 },
      { id: 'm2', name: 'Lanche da manhã', time: '10:30', description: 'Iogurte natural + granola + 30g whey', kcal: 320 },
      { id: 'm3', name: 'Almoço', time: '13:00', description: '150g frango, 100g arroz, salada, feijão', kcal: 720 },
      { id: 'm4', name: 'Pré-treino', time: '16:30', description: 'Pão integral + pasta de amendoim + café', kcal: 380 },
      { id: 'm5', name: 'Jantar', time: '20:00', description: '180g patinho moído, batata doce, brócolis', kcal: 640 },
    ],
  });
  console.log('🥗 Created DietPlan:', dietPlan.name);

  // 4. Sample WorkoutLogs — last week results from mock_data
  await WorkoutLog.deleteMany({ userId });
  const today = new Date();
  const monday = new Date(today);
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7) - 7); // last Monday

  const wednesday = new Date(monday);
  wednesday.setDate(monday.getDate() + 2);

  const friday = new Date(monday);
  friday.setDate(monday.getDate() + 4);

  await WorkoutLog.insertMany([
    {
      userId,
      date: monday,
      workoutDayId: 'a',
      workoutName: 'Treino A',
      focus: 'Peito + Tríceps',
      exercises: [
        { exerciseId: 'a1', exerciseName: 'Supino reto barra', sets: [
          { reps: 8, weight: 57.5 }, { reps: 8, weight: 57.5 }, { reps: 7, weight: 57.5 }, { reps: 6, weight: 57.5 },
        ], confirmed: true },
        { exerciseId: 'a2', exerciseName: 'Supino inclinado halteres', sets: [
          { reps: 10, weight: 20 }, { reps: 10, weight: 20 }, { reps: 9, weight: 20 },
        ], confirmed: true },
        { exerciseId: 'a3', exerciseName: 'Crucifixo máquina', sets: [
          { reps: 12, weight: 32.5 }, { reps: 12, weight: 32.5 }, { reps: 10, weight: 32.5 },
        ], confirmed: true },
        { exerciseId: 'a4', exerciseName: 'Tríceps corda', sets: [
          { reps: 12, weight: 22.5 }, { reps: 12, weight: 22.5 }, { reps: 12, weight: 22.5 }, { reps: 10, weight: 22.5 },
        ], confirmed: true },
      ],
    },
    {
      userId,
      date: wednesday,
      workoutDayId: 'b',
      workoutName: 'Treino B',
      focus: 'Costas + Bíceps',
      exercises: [
        { exerciseId: 'b1', exerciseName: 'Puxada frente', sets: [
          { reps: 10, weight: 50 }, { reps: 10, weight: 50 }, { reps: 9, weight: 50 }, { reps: 8, weight: 50 },
        ], confirmed: true },
        { exerciseId: 'b2', exerciseName: 'Remada curvada', sets: [
          { reps: 8, weight: 45 }, { reps: 8, weight: 45 }, { reps: 8, weight: 45 }, { reps: 7, weight: 45 },
        ], confirmed: true },
        { exerciseId: 'b3', exerciseName: 'Rosca direta', sets: [
          { reps: 12, weight: 12 }, { reps: 12, weight: 12 }, { reps: 11, weight: 12 },
        ], confirmed: true },
      ],
    },
    {
      userId,
      date: friday,
      workoutDayId: 'c',
      workoutName: 'Treino C',
      focus: 'Pernas + Glúteos',
      exercises: [
        { exerciseId: 'c1', exerciseName: 'Agachamento livre', sets: [
          { reps: 8, weight: 60 }, { reps: 8, weight: 60 }, { reps: 7, weight: 60 }, { reps: 6, weight: 60 },
        ], confirmed: true },
        { exerciseId: 'c2', exerciseName: 'Leg press 45°', sets: [
          { reps: 12, weight: 170 }, { reps: 12, weight: 170 }, { reps: 12, weight: 170 }, { reps: 10, weight: 170 },
        ], confirmed: true },
        { exerciseId: 'c3', exerciseName: 'Cadeira extensora', sets: [
          { reps: 15, weight: 40 }, { reps: 15, weight: 40 }, { reps: 13, weight: 40 },
        ], confirmed: true },
        { exerciseId: 'c4', exerciseName: 'Stiff', sets: [
          { reps: 10, weight: 45 }, { reps: 10, weight: 45 }, { reps: 10, weight: 45 },
        ], confirmed: true },
      ],
    },
  ]);
  console.log('📝 Created 3 WorkoutLog entries');

  // 5. Sample DietLog
  await DietLog.deleteMany({ userId });
  await DietLog.create({
    userId,
    date: monday,
    checkIns: [
      { mealId: 'm1', status: 'seguiu', note: '' },
      { mealId: 'm2', status: 'seguiu', note: '' },
      { mealId: 'm3', status: 'seguiu', note: '' },
      { mealId: 'm4', status: 'ajustou', note: 'Troquei café por suco' },
      { mealId: 'm5', status: 'seguiu', note: '' },
    ],
    freeMeals: [{ day: 'Domingo', description: 'Pizza com a família' }],
    cheatEntries: [],
  });
  console.log('🍽️ Created 1 DietLog entry');

  // 6. Sample Weight entries
  await Weight.deleteMany({ userId });
  const weightEntries = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(today.getDate() - i);
    weightEntries.push({
      userId,
      value: 58.5 + (Math.random() * 0.6 - 0.3), // ~58.2–58.8
      date: d,
    });
  }
  await Weight.insertMany(weightEntries);
  console.log('⚖️ Created', weightEntries.length, 'Weight entries');

  // 7. Sample Activity entries
  await Activity.deleteMany({ userId });
  await Activity.insertMany([
    { userId, type: 'yoga', durationMinutes: 45, source: 'manual', date: monday },
    { userId, type: 'corrida', durationMinutes: 30, source: 'garmin', date: wednesday },
  ]);
  console.log('🏃 Created 2 Activity entries');

  console.log('\n🎉 Seed complete!');
  await mongoose.disconnect();
  console.log('🔌 Disconnected from MongoDB');
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  mongoose.disconnect();
  process.exit(1);
});
