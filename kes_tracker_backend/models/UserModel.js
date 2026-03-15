const { pool } = require("../config/db");

const User = {
  create: async (userData) => {
    const {
      fullName,
      email,
      phone,
      hashedPassword,
      membershipId,
      subscriptionStatus,
    } = userData;
    const query = `
      INSERT INTO users (
        full_name, 
        email_address, 
        phone_number, 
        password_hash, 
        membership_id, 
        subscription_status
      )
      VALUES ($1, $2, $3, $4, $5, $6) 
      RETURNING 
        id, 
        full_name, 
        email_address as email, 
        phone_number, 
        membership_id, 
        subscription_status, 
        free_pdf_count,
        created_at;
    `;
    const values = [
      fullName,
      email,
      phone,
      hashedPassword,
      membershipId,
      subscriptionStatus || "free",
    ];

    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  findByPhone: async (phone) => {
    const query = "SELECT * FROM users WHERE phone_number = $1";
    const { rows } = await pool.query(query, [phone]);
    return rows[0];
  },

  findById: async (id) => {
    const query = `
      SELECT 
        id, 
        full_name, 
        email_address as email, 
        phone_number, 
        membership_id, 
        subscription_status, 
        free_pdf_count,
        created_at
      FROM users 
      WHERE id = $1
    `;
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  },

  incrementPdfCount: async (id) => {
    const query = `
      UPDATE users 
      SET free_pdf_count = free_pdf_count + 1 
      WHERE id = $1 
      RETURNING free_pdf_count;
    `;
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  },

  // --- NEW: PASSWORD RESET DATABASE LOGIC ---

  // Stores the code and sets an expiration timestamp (15 minutes from now)
  saveResetCode: async (phone, code) => {
    const query = `
      UPDATE users 
      SET reset_code = $1, 
          reset_code_expires = NOW() + INTERVAL '15 minutes'
      WHERE phone_number = $2;
    `;
    await pool.query(query, [code, phone]);
  },

  // Checks if the code matches AND if it hasn't expired yet
  verifyResetCode: async (phone, code) => {
    const query = `
      SELECT id FROM users 
      WHERE phone_number = $1 
      AND reset_code = $2 
      AND reset_code_expires > NOW();
    `;
    const { rows } = await pool.query(query, [phone, code]);
    return rows.length > 0;
  },

  // Updates the actual password hash
  updatePassword: async (phone, hashedPassword) => {
    const query = `
      UPDATE users 
      SET password_hash = $1 
      WHERE phone_number = $2;
    `;
    await pool.query(query, [hashedPassword, phone]);
  },

  // Clears the code after a successful reset for security
  clearResetCode: async (phone) => {
    const query = `
      UPDATE users 
      SET reset_code = NULL, 
          reset_code_expires = NULL 
      WHERE phone_number = $1;
    `;
    await pool.query(query, [phone]);
  },
};

module.exports = User;
