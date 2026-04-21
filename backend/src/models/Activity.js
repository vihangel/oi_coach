const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['yoga', 'corrida', 'crossfit', 'natacao', 'tenisDeMesa'],
    required: true,
  },
  durationMinutes: { type: Number, required: true, min: 1 },
  source: { type: String, enum: ['manual', 'garmin'], default: 'manual' },
  date: { type: Date, required: true },
}, { timestamps: true });

activitySchema.index({ date: -1 });

module.exports = mongoose.model('Activity', activitySchema);
