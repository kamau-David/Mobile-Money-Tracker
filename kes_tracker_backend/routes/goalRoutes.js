const express = require("express");
const router = express.Router();
const {
  createGoal,
  getUserGoals,
  addSavings,
} = require("../controllers/goalController");
const { protect } = require("../middleware/authMiddleware");

router.post("/", protect, createGoal);
router.get("/", protect, getUserGoals);
router.patch("/add-progress", protect, addSavings);

module.exports = router;
