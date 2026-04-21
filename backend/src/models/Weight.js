const mongoose = require('mongoose');

const weightSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  value: { type: Number, required: true, min: 30, max: 300 },
  date: { type: Date, required: true },
}, { timestamps: true });

weightSchema.index({ date: -1 });
weightSchema.index({ userId: 1 });

module.exports = mongoose.model('Weight', weightSchema);
