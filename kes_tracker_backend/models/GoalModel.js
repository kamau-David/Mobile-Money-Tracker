const { pool } = require("../config/db");

const Goal = {
  create: async (data) => {
    const query = `
      INSERT INTO goals (user_id, goal_name, target_amount, deadline, category)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const values = [
      data.userId,
      data.goalName,
      data.targetAmount,
      data.deadline,
      data.category,
    ];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },

  getSummary: async (userId) => {
    // This query calculates how much total money is "reserved" for goals
    const query = `
      SELECT 
        COUNT(*) as total_goals,
        SUM(target_amount) as total_target,
        SUM(current_saved) as total_saved
      FROM goals 
      WHERE user_id = $1 AND is_completed = false;
    `;
    const { rows } = await pool.query(query, [userId]);
    return rows[0];
  },

  updateProgress: async (goalId, userId, amount) => {
    const query = `
      UPDATE goals 
      SET current_saved = current_saved + $1,
          is_completed = (current_saved + $1 >= target_amount)
      WHERE id = $2 AND user_id = $3
      RETURNING *;
    `;
    const values = [amount, goalId, userId];
    const { rows } = await pool.query(query, values);
    return rows[0];
  },
};

module.exports = Goal;
