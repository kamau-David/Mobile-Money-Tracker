const express = require("express");
const router = express.Router();
const smsController = require("../controllers/smsController");

router.post("/parse-sms", smsController.parseAndSaveSMS);
router.get("/transactions", smsController.getAllTransactions);
router.get("/summary", smsController.getFinanceSummary);

module.exports = router;
