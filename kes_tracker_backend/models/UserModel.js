const { pool } = require("../config/db");

const User = {
  create: async (userData) => {
    const { fullName, email, phone, hashedPassword } = userData;
    const query = `
      INSERT INTO users (full_name, email_address,phone_number, password_hash)
      VALUES ($1, $2) RETURNING id, full_name, email_address, phone_number;
    `;
    const values = [fullName, email, phone, hashedPassword];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  findById: async (id) => {
    const query =
      "SELECT id, full_name, email_address, phone_number FROM users WHERE id = $1";
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  },
};

module.exports = User;
