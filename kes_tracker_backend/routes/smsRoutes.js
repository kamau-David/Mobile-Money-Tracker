const express = require("express");
const router = express.Router();

const {
  parseAndSaveSMS,
  getAllTransactions,
  getFinanceSummary,
  updateTransaction,
  getPendingClarifications,
  getCategoryBreakdown,
  searchTransactions,
  getTransactionsByDate,
} = require("../controllers/smsController");

const { protect } = require("../middleware/authMiddleware");


router.post("/parse-sms", protect, parseAndSaveSMS);
router.get("/transactions", protect, getAllTransactions);
router.get("/summary", protect, getFinanceSummary);
router.patch("/update/:id", protect, updateTransaction);
router.get("/pending", protect, getPendingClarifications);
router.get("/charts/categories", protect, getCategoryBreakdown);
router.get("/search", protect, searchTransactions);
router.get("/filter", protect, getTransactionsByDate);

module.exports = router;
