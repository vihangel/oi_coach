const mongoose = require('mongoose');

const weightSchema = new mongoose.Schema({
  value: { type: Number, required: true, min: 30, max: 300 },
  date: { type: Date, required: true },
}, { timestamps: true });

weightSchema.index({ date: -1 });

module.exports = mongoose.model('Weight', weightSchema);
