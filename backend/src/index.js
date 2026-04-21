require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const workoutRoutes = require('./routes/workouts');
const dietRoutes = require('./routes/diet');
const progressRoutes = require('./routes/progress');
const activityRoutes = require('./routes/activities');
const weightRoutes = require('./routes/weight');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (_, res) => res.json({ status: 'ok' }));

// Routes
app.use('/api/workouts', workoutRoutes);
app.use('/api/diet', dietRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/weight', weightRoutes);

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => console.log(`API running on port ${PORT}`));
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });
