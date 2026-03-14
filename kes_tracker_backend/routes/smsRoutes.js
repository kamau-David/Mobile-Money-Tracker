const express = require("express");
const router = express.Router();

// Destructure ONLY the SMS controller
const {
  parseAndSaveSMS,
  getAllTransactions,
  getFinanceSummary,
} = require("../controllers/smsController");

const { protect } = require("../middleware/authMiddleware");
const reportController = require("../controllers/reportController");

router.post("/parse-sms", protect, parseAndSaveSMS);
router.get("/transactions", protect, getAllTransactions);
router.get("/summary", protect, getFinanceSummary);

router.get("/download-report", protect, reportController.generatePDF);

module.exports = router;
