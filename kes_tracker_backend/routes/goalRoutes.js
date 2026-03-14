const express = require("express");
const router = express.Router();
const { createGoal, getUserGoals } = require("../controllers/goalController");
const { protect } = require("../middleware/authMiddleware");

router.post("/", protect, createGoal);
router.get("/", protect, getUserGoals);

module.exports = router;
