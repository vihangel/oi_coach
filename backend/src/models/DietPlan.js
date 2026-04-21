const mongoose = require('mongoose');

const mealSchema = new mongoose.Schema({
  id: { type: String, required: true },
  name: { type: String, required: true },
  time: { type: String, required: true },
  description: { type: String, required: true },
  kcal: { type: Number, required: true },
}, { _id: false });

const dietPlanSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  meals: [mealSchema],
}, { timestamps: true });

dietPlanSchema.index({ userId: 1 });

module.exports = mongoose.model('DietPlan', dietPlanSchema);
