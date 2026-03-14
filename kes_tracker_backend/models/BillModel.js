const { pool } = require("../config/db");

const Bill = {
  // 1. Create a new recurring bill (e.g., Rent, Zuku, KPLC)
  create: async (data) => {
    const query = `
      INSERT INTO bills (user_id, merchant_name, amount_expected, due_date_day, category)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const values = [
      data.userId,
      data.merchantName,
      data.amountExpected,
      data.dueDateDay,
      data.category,
    ];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  // 2. Fetch all active bills for a specific user
  findByUser: async (userId) => {
    const query = `
      SELECT * FROM bills 
      WHERE user_id = $1 AND is_active = true 
      ORDER BY due_date_day ASC;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows;
  },

  // 3. Update the "last_paid_date" when a matching M-Pesa SMS is parsed
  markAsPaid: async (billId, date) => {
    const query = `
      UPDATE bills 
      SET last_paid_date = $1 
      WHERE id = $2 
      RETURNING *;
    `;
    const { rows } = await pool.query(query, [date, billId]);
    return rows[0];
  },

  // 4. Delete or Deactivate a bill
  delete: async (billId, userId) => {
    const query =
      "DELETE FROM bills WHERE id = $1 AND user_id = $2 RETURNING *;";
    const { rows } = await pool.query(query, [billId, userId]);
    return rows[0];
  },
};

module.exports = Bill;
