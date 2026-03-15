const { pool } = require("../config/db");

const User = {
  // Updated to return subscription fields upon registration
  create: async (userData) => {
    const { fullName, email, phone, hashedPassword } = userData;
    const query = `
      INSERT INTO users (full_name, email_address, phone_number, password_hash)
      VALUES ($1, $2, $3, $4) 
      RETURNING id, full_name, email_address, phone_number, subscription_status, free_pdf_count;
    `;
    const values = [fullName, email, phone, hashedPassword];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  // Already selects all columns, including new subscription fields
  findByPhone: async (phone) => {
    const query = "SELECT * FROM users WHERE phone_number = $1";
    const { rows } = await pool.query(query, [phone]);
    return rows[0];
  },

  // Updated to specifically select subscription fields for the session/auth logic
  findById: async (id) => {
    const query = `
      SELECT id, full_name, email_address, phone_number, subscription_status, free_pdf_count 
      FROM users 
      WHERE id = $1
    `;
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  },

  // Helper method to increment the PDF count (We'll use this in Step 3)
  incrementPdfCount: async (id) => {
    const query = `
      UPDATE users 
      SET free_pdf_count = free_pdf_count + 1 
      WHERE id = $1 
      RETURNING free_pdf_count;
    `;
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  }
};

module.exports = User;