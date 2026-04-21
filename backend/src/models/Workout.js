const mongoose = require('mongoose');

const exerciseSetSchema = new mongoose.Schema({
  reps: { type: Number, required: true },
  weight: { type: Number, required: true },
}, { _id: false });

const exerciseLogSchema = new mongoose.Schema({
  exerciseId: { type: String, required: true },
  exerciseName: { type: String, required: true },
  sets: [exerciseSetSchema],
  confirmed: { type: Boolean, default: false },
}, { _id: false });

const workoutLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  workoutDayId: { type: String, required: true },
  workoutName: { type: String, required: true },
  focus: { type: String, required: true },
  exercises: [exerciseLogSchema],
}, { timestamps: true });

workoutLogSchema.index({ date: -1 });
workoutLogSchema.index({ userId: 1 });

module.exports = mongoose.model('WorkoutLog', workoutLogSchema);
