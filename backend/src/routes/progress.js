const router = require('express').Router();
const WorkoutLog = require('../models/Workout');

// GET /api/progress — compares last 2 workout sessions per exercise
router.get('/', async (req, res) => {
  try {
    const twoWeeksAgo = new Date(Date.now() - 14 * 86400000);
    const logs = await WorkoutLog.find({ userId: req.userId, date: { $gte: twoWeeksAgo } })
      .sort({ date: -1 });

    if (logs.length < 2) {
      return res.json({ entries: [], message: 'Need at least 2 sessions' });
    }

    const current = logs[0];
    const previous = logs.find(
      (l) => l.workoutDayId === current.workoutDayId && l._id !== current._id
    );

    if (!previous) {
      return res.json({ entries: [], message: 'No previous session found' });
    }

    const entries = current.exercises.map((ex) => {
      const prevEx = previous.exercises.find((p) => p.exerciseId === ex.exerciseId);
      const currentTopWeight = Math.max(...ex.sets.map((s) => s.weight), 0);
      const currentTopReps = Math.max(...ex.sets.map((s) => s.reps), 0);
      const previousTopWeight = prevEx
        ? Math.max(...prevEx.sets.map((s) => s.weight), 0)
        : 0;
      const previousTopReps = prevEx
        ? Math.max(...prevEx.sets.map((s) => s.reps), 0)
        : 0;

      return {
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        currentWeight: currentTopWeight,
        currentReps: currentTopReps,
        previousWeight: previousTopWeight,
        previousReps: previousTopReps,
        weightDelta: currentTopWeight - previousTopWeight,
        repsDelta: currentTopReps - previousTopReps,
      };
    });

    res.json({ entries });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
