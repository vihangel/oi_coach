const router = require('express').Router();
const Activity = require('../models/Activity');

// GET /api/activities?date=2024-01-15
router.get('/', async (req, res) => {
  try {
    const { date } = req.query;
    const filter = { userId: req.userId };
    if (date) {
      const d = new Date(date);
      filter.date = { $gte: d, $lt: new Date(d.getTime() + 86400000) };
    }
    const activities = await Activity.find(filter).sort({ date: -1 });
    res.json(activities);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/activities
router.post('/', async (req, res) => {
  try {
    const activity = await Activity.create({ ...req.body, userId: req.userId });
    res.status(201).json(activity);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE /api/activities/:id
router.delete('/:id', async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity) return res.status(404).json({ error: 'Not found' });
    if (activity.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Acesso negado' });
    }
    await activity.deleteOne();
    res.json({ deleted: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
