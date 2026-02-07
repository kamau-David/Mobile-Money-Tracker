const db = require('../config/db');


exports.addTransaction = async (req, res) => {
    
    const { amount, description, type, category, mpesa_code, raw_sms } = req.body;
    const user_id = req.user.id; 

    try {
        const [result] = await db.query(
            `INSERT INTO transactions 
            (user_id, amount, description, type, category, mpesa_code, raw_sms) 
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [user_id, amount, description, type, category || 'Uncategorized', mpesa_code, raw_sms]
        );

        res.status(201).json({ 
            message: 'Transaction recorded! 🤖💰', 
            transactionId: result.insertId 
        });
    } catch (error) {
        
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'This transaction (M-Pesa code) has already been saved.' });
        }
        console.error(error);
        res.status(500).json({ message: 'Error saving transaction' });
    }
};


exports.getTransactions = async (req, res) => {
    const user_id = req.user.id;
    try {
        const [rows] = await db.query(
            'SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC', 
            [user_id]
        );
        res.status(200).json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching transactions' });
    }
};