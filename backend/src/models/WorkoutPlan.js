const mongoose = require('mongoose');

const exerciseSchema = new mongoose.Schema({
  id: { type: String, required: true },
  order: { type: Number, required: true },
  name: { type: String, required: true },
  targetSets: { type: Number, required: true },
  targetReps: { type: String, required: true },
  targetWeight: { type: Number, required: true },
}, { _id: false });

const workoutDaySchema = new mongoose.Schema({
  id: { type: String, required: true },
  name: { type: String, required: true },
  focus: { type: String, required: true },
  day: { type: String, required: true },
  exercises: [exerciseSchema],
}, { _id: false });

const workoutPlanSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  days: [workoutDaySchema],
}, { timestamps: true });

workoutPlanSchema.index({ userId: 1 });

module.exports = mongoose.model('WorkoutPlan', workoutPlanSchema);
