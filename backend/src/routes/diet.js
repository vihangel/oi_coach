const router = require('express').Router();
const DietLog = require('../models/Diet');

// GET /api/diet?date=2024-01-15
router.get('/', async (req, res) => {
  try {
    const { date } = req.query;
    const filter = { userId: req.userId };
    if (date) {
      const d = new Date(date);
      filter.date = { $gte: d, $lt: new Date(d.getTime() + 86400000) };
    }
    const logs = await DietLog.find(filter).sort({ date: -1 }).limit(50);
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/diet
router.post('/', async (req, res) => {
  try {
    const log = await DietLog.create({ ...req.body, userId: req.userId });
    res.status(201).json(log);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /api/diet/:id
router.put('/:id', async (req, res) => {
  try {
    const log = await DietLog.findById(req.params.id);
    if (!log) return res.status(404).json({ error: 'Not found' });
    if (log.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Acesso negado' });
    }
    const updated = await DietLog.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
