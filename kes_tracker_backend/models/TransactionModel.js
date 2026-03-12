const { pool } = require("../config/db");

const Transaction = {
  create: async (data) => {
    const query = `
      INSERT INTO transactions (transaction_id, amount, merchant, category, type, sms_raw, needs_clarification)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (transaction_id) DO NOTHING
      RETURNING *;
    `;
    const values = [
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

  findAll: async () => {
    const { rows } = await pool.query(
      "SELECT * FROM transactions ORDER BY created_at DESC;",
    );
    return rows;
  },

  getSummary: async () => {
    const query = `
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
      FROM transactions;
    `;
    const { rows } = await pool.query(query);
    const totals = rows[0];
    const balance =
      parseFloat(totals.total_income || 0) -
      parseFloat(totals.total_expense || 0);

    return {
      totalIncome: totals.total_income || 0,
      totalExpense: totals.total_expense || 0,
      currentBalance: balance,
    };
  },
};

module.exports = Transaction;
