const { pool } = require("../config/db");

const Transaction = {
  // 1. Create: Now includes user_id
  create: async (data) => {
    const query = `
      INSERT INTO transactions (user_id, transaction_id, amount, merchant, category, type, sms_raw, needs_clarification)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (transaction_id) DO NOTHING
      RETURNING *;
    `;
    const values = [
      data.userId, // <--- Linked to the logged-in user
      data.transactionId,
      data.amount,
      data.merchant,
      data.category,
      data.type,
      data.smsRaw,
      data.needsClarification,
    ];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  // 2. FindAll: Now filters by userId
  findAll: async (userId) => {
    const query =
      "SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC;";
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 3. GetSummary: Now calculates only for the specific user
  getSummary: async (userId) => {
    const query = `
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
      FROM transactions
      WHERE user_id = $1;
    `;
    const { rows } = await pool.query(query, [userId]);
    const totals = rows[0];

    const totalIncome = parseFloat(totals.total_income || 0);
    const totalExpense = parseFloat(totals.total_expense || 0);
    const balance = totalIncome - totalExpense;

    return {
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      currentBalance: balance,
    };
  },
};

module.exports = Transaction;
