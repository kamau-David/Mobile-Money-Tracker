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

exports.addSavings = async (req, res) => {
  try {
    const { goalId, amount } = req.body;
    const userId = req.user;

    if (!amount || amount <= 0) {
      return res
        .status(400)
        .json({ error: "Please provide a valid savings amount" });
    }

    const updatedGoal = await Goal.updateProgress(goalId, userId, amount);

    if (!updatedGoal) {
      return res.status(404).json({ error: "Goal not found" });
    }

    res.status(200).json({
      success: true,
      message: updatedGoal.is_completed
        ? `Kongole! You've reached your goal: ${updatedGoal.goal_name}!`
        : `Progress updated for ${updatedGoal.goal_name}`,
      goal: updatedGoal,
    });
  } catch (error) {
    console.error("Update Progress Error:", error);
    res.status(500).json({ error: "Failed to update goal progress" });
  }
};
