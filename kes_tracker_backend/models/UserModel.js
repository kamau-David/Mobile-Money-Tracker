const { pool } = require("../config/db");

const User = {
  // Updated to include membership_id and subscription fields
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
        email_address, 
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

  // Already selects all columns (*), which now includes membership_id
  findByPhone: async (phone) => {
    const query = "SELECT * FROM users WHERE phone_number = $1";
    const { rows } = await pool.query(query, [phone]);
    return rows[0];
  },

  // Updated to select membership_id and other crucial auth fields
  findById: async (id) => {
    const query = `
      SELECT 
        id, 
        full_name, 
        email_address, 
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

  // Helper method to increment the PDF count for free tier tracking
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
};

module.exports = User;
