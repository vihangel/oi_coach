const router = require('express').Router();
const DietPlan = require('../models/DietPlan');

// GET /api/diet-plans — list plans filtered by req.userId
router.get('/', async (req, res) => {
  try {
    const plans = await DietPlan.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json(plans);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/diet-plans — create plan with req.userId
router.post('/', async (req, res) => {
  try {
    const plan = await DietPlan.create({ ...req.body, userId: req.userId });
    res.status(201).json(plan);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT /api/diet-plans/:id — update plan owned by req.userId
router.put('/:id', async (req, res) => {
  try {
    const plan = await DietPlan.findById(req.params.id);
    if (!plan) {
      return res.status(404).json({ message: 'Plano não encontrado' });
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
