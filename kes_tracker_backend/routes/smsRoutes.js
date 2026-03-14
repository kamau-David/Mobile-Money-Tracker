const express = require("express");
const router = express.Router();

// Destructure ONLY the SMS controller
const {
  parseAndSaveSMS,
  getAllTransactions,
  getFinanceSummary,
  updateTransaction,
  getPendingClarifications,
  getCategoryBreakdown,
  searchTransactions
} = require("../controllers/smsController");

const { protect } = require("../middleware/authMiddleware");
const reportController = require("../controllers/reportController");

router.post("/parse-sms", protect, parseAndSaveSMS);
router.get("/transactions", protect, getAllTransactions);
router.get("/summary", protect, getFinanceSummary);
router.patch("/update/:id", protect, updateTransaction);
router.get("/download-report", protect, reportController.generatePDF);
router.get("/pending", protect, getPendingClarifications);
router.get("/charts/categories", protect, getCategoryBreakdown);
router.get("/search", protect, searchTransactions);

module.exports = router;
