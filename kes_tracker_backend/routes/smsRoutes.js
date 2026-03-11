const express = require("express");
const router = express.Router();
const smsController = require("../controllers/smsController");

// Define the route
router.post("/parse-sms", smsController.parseAndSaveSMS);

module.exports = router;
