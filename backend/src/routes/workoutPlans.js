const router = require('express').Router();
const WorkoutPlan = require('../models/WorkoutPlan');

// GET /api/workout-plans — list plans filtered by req.userId
router.get('/', async (req, res) => {
  try {
    const plans = await WorkoutPlan.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json(plans);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/workout-plans — create plan with req.userId
router.post('/', async (req, res) => {
  try {
    const plan = await WorkoutPlan.create({ ...req.body, userId: req.userId });
    res.status(201).json(plan);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /api/workout-plans/:id — update plan owned by req.userId
router.put('/:id', async (req, res) => {
  try {
    const plan = await WorkoutPlan.findById(req.params.id);
    if (!plan) {
      return res.status(404).json({ message: 'Ficha não encontrada' });
    }
    if (plan.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Acesso negado' });
    }
    Object.assign(plan, req.body);
    plan.userId = req.userId; // preserve ownership
    await plan.save();
    res.json(plan);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
