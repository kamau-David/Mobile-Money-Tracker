const { pool } = require("../config/db");

const Transaction = {
  // 1. Create: Updated to include post_balance
  create: async (data) => {
    const query = `
      INSERT INTO transactions (user_id, transaction_id, amount, merchant, category, type, sms_raw, post_balance, needs_clarification)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
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
      data.postBalance, // Passed from your updated smsController
      data.needsClarification,
    ];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  // 2. FindAll (Ordered by newest first)
  findAll: async (userId) => {
    const query =
      "SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC;";
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 3. GetSummary (Optimized to show actual M-Pesa balance)
  getSummary: async (userId) => {
    // This query gets the totals AND the very latest post_balance recorded
    const query = `
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
        (SELECT post_balance FROM transactions WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1) as latest_mpesa_balance
      FROM transactions
      WHERE user_id = $1;
    `;
    const { rows } = await pool.query(query, [userId]);
    const totals = rows[0];

    return {
      totalIncome: parseFloat(totals.total_income || 0),
      totalExpense: parseFloat(totals.total_expense || 0),
      // If we have a post_balance, use it. Otherwise, fallback to calculated balance.
      currentBalance: totals.latest_mpesa_balance
        ? parseFloat(totals.latest_mpesa_balance)
        : parseFloat(totals.total_income || 0) -
          parseFloat(totals.total_expense || 0),
    };
  },

  // 4. Update
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

  // 5. FindPending
  findPending: async (userId) => {
    const query =
      "SELECT * FROM transactions WHERE user_id = $1 AND needs_clarification = true ORDER BY created_at DESC;";
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 6. GetCategoryTotals
  getCategoryTotals: async (userId) => {
    const query = `
      SELECT category, SUM(amount) as total 
      FROM transactions 
      WHERE user_id = $1 AND type = 'expense'
      GROUP BY category
      ORDER BY total DESC;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 7. Search
  search: async (userId, searchTerm) => {
    const query = `
      SELECT * FROM transactions 
      WHERE user_id = $1 
      AND (merchant ILIKE $2 OR category ILIKE $2 OR transaction_id ILIKE $2)
      ORDER BY created_at DESC;
    `;
    const values = [userId, `%${searchTerm}%`];
    const { rows } = await pool.query(query, values);
    return rows;
  },

  // 8. Filter by Date
  filterByDate: async (userId, startDate, endDate) => {
    const query = `
      SELECT * FROM transactions 
      WHERE user_id = $1 
      AND created_at BETWEEN $2 AND $3
      ORDER BY created_at DESC;
    `;
    const values = [userId, startDate, endDate];
    const { rows } = await pool.query(query, values);
    return rows;
  },

  // 9. findForReport (Used by PDF engine)
  findForReport: async (userId, filters) => {
    let query = "SELECT * FROM transactions WHERE user_id = $1";
    const values = [userId];
    let paramIndex = 2;

    if (filters.category) {
      query += ` AND category = $${paramIndex++}`;
      values.push(filters.category);
    }
    if (filters.startDate && filters.endDate) {
      query += ` AND created_at BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
      values.push(filters.startDate, filters.endDate);
      paramIndex += 2;
    }
    if (filters.transactionId) {
      query += ` AND id = $${paramIndex++}`;
      values.push(filters.transactionId);
    }

    query += " ORDER BY created_at ASC;";
    const { rows } = await pool.query(query, values);
    return rows;
  },

  // 10. getDailyTrends (For PDF charts)
  getDailyTrends: async (userId, startDate, endDate) => {
    const query = `
      SELECT 
        DATE(created_at) as date,
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as expense
      FROM transactions
      WHERE user_id = $1 AND created_at BETWEEN $2 AND $3
      GROUP BY DATE(created_at)
      ORDER BY date ASC;
    `;
    const values = [userId, startDate, endDate];
    const { rows } = await pool.query(query, values);
    return rows;
  },

  // 11. getAdvancedCategoryStats
  getAdvancedCategoryStats: async (userId) => {
    const query = `
      SELECT 
        category, 
        SUM(amount) as total_amount,
        COUNT(*) as count,
        ROUND((SUM(amount) / NULLIF(SUM(SUM(amount)) OVER (), 0)) * 100, 1) as percentage
      FROM transactions 
      WHERE user_id = $1 AND type = 'expense'
      GROUP BY category
      ORDER BY total_amount DESC;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },
};

module.exports = Transaction;
