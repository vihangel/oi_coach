/** @format */

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

const path = require("path");

const authRoutes = require("./routes/auth");
const workoutRoutes = require("./routes/workouts");
const dietRoutes = require("./routes/diet");
const progressRoutes = require("./routes/progress");
const activityRoutes = require("./routes/activities");
const weightRoutes = require("./routes/weight");
const workoutPlanRoutes = require("./routes/workoutPlans");
const dietPlanRoutes = require("./routes/dietPlans");
const authMiddleware = require("./middleware/auth");

// Print 3D module
const print3dRoutes = require("./print3d/routes");
const print3dPublicRoutes = require("./print3d/publicRoutes");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.use("/uploads", express.static(path.join(__dirname, "..", "uploads")));

// Health check
app.get("/health", (_, res) => res.json({ status: "ok" }));

// Auth routes (public, no middleware)
app.use("/api/auth", authRoutes);

// Protected routes (require auth)
app.use("/api/workouts", authMiddleware, workoutRoutes);
app.use("/api/diet", authMiddleware, dietRoutes);
app.use("/api/workout-plans", authMiddleware, workoutPlanRoutes);
app.use("/api/diet-plans", authMiddleware, dietPlanRoutes);
app.use("/api/activities", authMiddleware, activityRoutes);
app.use("/api/weight", authMiddleware, weightRoutes);
app.use("/api/progress", authMiddleware, progressRoutes);

// Print 3D — rotas publicas (cliente final)
app.use("/api/3d", print3dPublicRoutes);

// Print 3D — rotas protegidas (admin)
app.use("/api/3d", authMiddleware, print3dRoutes);

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log("Connected to MongoDB");
    app.listen(PORT, () => console.log(`API running on port ${PORT}`));
  })
  .catch((err) => {
    console.error("MongoDB connection error:", err.message);
    process.exit(1);
  });
