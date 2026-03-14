const express = require("express");
const router = express.Router();
const { getUpcomingReminders,getForecast } = require("../controllers/insightController");
const { protect } = require("../middleware/authMiddleware");



router.get("/reminders", protect, getUpcomingReminders);
router.get("/forecast", protect, getForecast); // Now this works!


module.exports = router;