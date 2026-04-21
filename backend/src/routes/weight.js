const router = require('express').Router();
const Weight = require('../models/Weight');

// GET /api/weight/latest — current + previous
router.get('/latest', async (req, res) => {
  try {
    const entries = await Weight.find().sort({ date: -1 }).limit(2);
    const current = entries[0] || null;
    const previous = entries[1] || null;
    res.json({ current, previous });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/weight
router.post('/', async (req, res) => {
  try {
    const { value, date } = req.body;
    if (value < 30 || value > 300) {
      return res.status(400).json({ error: 'Peso deve estar entre 30kg e 300kg' });
    }
    const entry = await Weight.create({ value, date: date || new Date() });
    res.status(201).json(entry);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /api/weight/history?limit=30
router.get('/history', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 30;
    const entries = await Weight.find().sort({ date: -1 }).limit(limit);
    res.json(entries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
