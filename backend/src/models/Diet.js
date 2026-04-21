const mongoose = require('mongoose');

const mealCheckInSchema = new mongoose.Schema({
  mealId: { type: String, required: true },
  status: { type: String, enum: ['seguiu', 'ajustou', 'nao'], required: true },
  note: { type: String, default: '' },
}, { _id: false });

const freeMealSchema = new mongoose.Schema({
  day: { type: String, default: '' },
  description: { type: String, default: '' },
}, { _id: false });

const cheatEntrySchema = new mongoose.Schema({
  description: { type: String, default: '' },
}, { _id: false });

const dietLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  checkIns: [mealCheckInSchema],
  freeMeals: [freeMealSchema],
  cheatEntries: [cheatEntrySchema],
}, { timestamps: true });

dietLogSchema.index({ date: -1 });
dietLogSchema.index({ userId: 1 });

module.exports = mongoose.model('DietLog', dietLogSchema);
