const { pool } = require("../config/db");

const Transaction = {
  // 1. Create: Linked to the logged-in user
  create: async (data) => {
    const query = `
      INSERT INTO transactions (user_id, transaction_id, amount, merchant, category, type, sms_raw, needs_clarification)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (transaction_id) DO NOTHING
      RETURNING *;
    `;
    const values = [
      data.userId,
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

  // 2. FindAll: Filters by userId
  findAll: async (userId) => {
    const query =
      "SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC;";
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 3. GetSummary: Aggregates totals for the specific user
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

  // 4. Update method for user clarifications
  update: async (id, userId, updates) => {
    const { category, needsClarification } = updates;

    const query = `
      UPDATE transactions 
      SET category = $1, needs_clarification = $2 
      WHERE id = $3 AND user_id = $4 
      RETURNING *;
    `;

    const values = [category, needsClarification, id, userId];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  // 5. FindPending: Get transactions needing review
  findPending: async (userId) => {
    const query = `
      SELECT * FROM transactions 
      WHERE user_id = $1 AND needs_clarification = true 
      ORDER BY created_at DESC;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 6. GetCategoryTotals: For chart data
  getCategoryTotals: async (userId) => {
    const query = `
      SELECT category, SUM(amount) as total 
      FROM transactions 
      WHERE user_id = $1 AND type = 'expense'
      GROUP BY category;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 7. Search: Find transactions by keyword
  search: async (userId, searchTerm) => {
    const query = `
      SELECT * FROM transactions 
      WHERE user_id = $1 
      AND (
        merchant ILIKE $2 OR 
        category ILIKE $2 OR 
        transaction_id ILIKE $2
      )
      ORDER BY created_at DESC;
    `;
    const values = [userId, `%${searchTerm}%`];
    const { rows } = await pool.query(query, values);
    return rows;
  },

  // 8. Filter by Date: Get transactions for a specific period
  filterByDate: async (userId, startDate, endDate) => {
    const query = `
      SELECT * FROM transactions 
      WHERE user_id = $1 
      AND created_at BETWEEN $2 AND $3
      ORDER BY created_at DESC;
    `;
    // We expect dates in YYYY-MM-DD format
    const values = [userId, startDate, endDate];
    const { rows } = await pool.query(query, values);
    return rows;
  },
};

module.exports = Transaction;
