const Goal = require("../models/GoalModel");

exports.createGoal = async (req, res) => {
  try {
    const { goalName, targetAmount, deadline, category } = req.body;

    // Validate inputs
    if (!goalName || !targetAmount) {
      return res
        .status(400)
        .json({ error: "Goal name and target amount are required" });
    }

    const newGoal = await Goal.create({
      userId: req.user, 
      goalName,
      targetAmount,
      deadline,
      category,
    });

    res.status(201).json({
      success: true,
      message: "Goal set! Now let's save for it.",
      goal: newGoal,
    });
  } catch (error) {
    console.error("Create Goal Error:", error);
    res.status(500).json({ error: "Failed to create savings goal" });
  }
};

exports.getUserGoals = async (req, res) => {
  try {
    const goals = await Goal.findByUser(req.user);
    res.status(200).json({ success: true, goals });
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch goals" });
  }
};
