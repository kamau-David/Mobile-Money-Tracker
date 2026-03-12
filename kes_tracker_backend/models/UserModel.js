const { pool } = require("../config/db");

const User = {
  create: async (phone, hashedPassword) => {
    const query = `
      INSERT INTO users (phone_number, password_hash)
      VALUES ($1, $2) RETURNING id, phone_number;
    `;
    const { rows } = await pool.query(query, [phone, hashedPassword]);
    return rows[0];
  },

  findByPhone: async (phone) => {
    const { rows } = await pool.query(
      "SELECT * FROM users WHERE phone_number = $1",
      [phone],
    );
    return rows[0];
  },
};

module.exports = User;
