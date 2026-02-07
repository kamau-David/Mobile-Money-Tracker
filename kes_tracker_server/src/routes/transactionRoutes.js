const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const auth = require('../middleware/authMiddleware'); 

router.post('/add', auth, transactionController.addTransaction);
router.get('/all', auth, transactionController.getTransactions);

module.exports = router;