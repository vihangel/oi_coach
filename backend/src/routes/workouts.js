const router = require('express').Router();
const WorkoutLog = require('../models/Workout');

// GET /api/workouts?date=2024-01-15
router.get('/', async (req, res) => {
  try {
    const { date } = req.query;
    const filter = {};
    if (date) {
      const d = new Date(date);
      filter.date = { $gte: d, $lt: new Date(d.getTime() + 86400000) };
    }
    const logs = await WorkoutLog.find(filter).sort({ date: -1 }).limit(50);
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/workouts
router.post('/', async (req, res) => {
  try {
    const log = await WorkoutLog.create(req.body);
    res.status(201).json(log);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /api/workouts/latest — last 2 weeks for progress comparison
router.get('/latest', async (req, res) => {
  try {
    const twoWeeksAgo = new Date(Date.now() - 14 * 86400000);
    const logs = await WorkoutLog.find({ date: { $gte: twoWeeksAgo } })
      .sort({ date: -1 });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
