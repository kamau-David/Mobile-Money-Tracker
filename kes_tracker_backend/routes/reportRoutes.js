const express = require("express");
const router = express.Router();
const reportController = require("../controllers/reportController");
const { protect } = require("../middleware/authMiddleware");


router.get("/download", protect, reportController.generatePDF);

module.exports = router;
