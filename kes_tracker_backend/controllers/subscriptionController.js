const User = require("../models/UserModel");

exports.upgradeToPro = async (req, res) => {
  try {
    const userId = req.user; 

    const query = `
      UPDATE users 
      SET subscription_status = 'pro' 
      WHERE id = $1 
      RETURNING id, full_name, subscription_status;
    `;

    const { pool } = require("../config/db");
    const { rows } = await pool.query(query, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      success: true,
      message: "Congratulations! You are now a KES Tracker Pro member.",
      user: rows[0],
    });
  } catch (error) {
    console.error("Upgrade Error:", error);
    res.status(500).json({ error: "Failed to upgrade subscription" });
  }
};
