const Bill = require("../models/BillModel");
const Transaction = require("../models/TransactionModel");
const Goal = require("../models/GoalModel"); // NEW IMPORT
const { pool } = require("../config/db");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// 1. REMINDERS LOGIC
exports.getUpcomingReminders = async (req, res) => {
  try {
    const userId = req.user;
    const today = new Date();
    const currentDay = today.getDate();

    // Fetch User's name for personalization
    const userResult = await pool.query(
      "SELECT full_name FROM users WHERE id = $1",
      [userId],
    );
    const firstName = userResult.rows[0]?.full_name.split(" ")[0] || "David";

    const bills = await Bill.findByUser(userId);
    let reminders = [];

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
    });

    for (let bill of bills) {
      if (
        bill.due_date_day > currentDay &&
        bill.due_date_day <= currentDay + 3
      ) {
        const prompt = `${firstName} has a bill for ${bill.merchant_name} (KES ${bill.amount_expected}) due on the ${bill.due_date_day}th. 
        It's now the ${currentDay}th. Write a short, friendly Kenyan-style reminder. 
        Ask about his plans for this payment. Be supportive, use a touch of Sheng or local context.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;

        reminders.push({
          merchant: bill.merchant_name,
          amount: bill.amount_expected,
          dueDate: bill.due_date_day,
          aiMessage: response.text(),
        });
      }
    }

    res.status(200).json({ success: true, reminders });
  } catch (error) {
    console.error("Insight Error (Reminders):", error);
    res
      .status(500)
      .json({ error: "Failed to generate reminders", details: error.message });
  }
};

// 2. FORECAST LOGIC (Now with Savings Goal Awareness)
exports.getForecast = async (req, res) => {
  try {
    const userId = req.user;

    // A. Fetch User's Name
    const userResult = await pool.query(
      "SELECT full_name FROM users WHERE id = $1",
      [userId],
    );
    const firstName = userResult.rows[0]?.full_name.split(" ")[0] || "David";

    // B. Get actual M-Pesa balance
    const summary = await Transaction.getSummary(userId);
    const currentBalance = summary.currentBalance;

    // C. Get "Reserved" money from Goals
    const goalSummary = await Goal.getSummary(userId);
    const totalGoalTarget = parseFloat(goalSummary.total_target || 0);
    const totalSavedSoFar = parseFloat(goalSummary.total_saved || 0);

    // Math: How much is David actually allowed to spend?
    const spendableBalance =
      currentBalance - (totalGoalTarget - totalSavedSoFar);

    // D. Burn Rate Calculation
    const burnRateQuery = `
      SELECT AVG(daily_total) as avg_burn
      FROM (
        SELECT SUM(amount) as daily_total
        FROM transactions
        WHERE user_id = $1 AND type = 'expense' 
        AND created_at > NOW() - INTERVAL '7 days'
        GROUP BY DATE(created_at)
      ) as daily_expenses;
    `;

    const burnResult = await pool.query(burnRateQuery, [userId]);
    const avgBurn = parseFloat(burnResult.rows[0].avg_burn || 0);

    if (avgBurn === 0 || isNaN(avgBurn)) {
      return res.json({
        success: true,
        message: "Not enough data to forecast yet.",
      });
    }

    const daysLeft = Math.floor(currentBalance / avgBurn);
    const exhaustionDate = new Date();
    exhaustionDate.setDate(exhaustionDate.getDate() + daysLeft);

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
    });

    // E. Updated Smart AI Prompt
    const prompt = `${firstName} has KES ${currentBalance} in M-Pesa. 
    He needs to save KES ${totalGoalTarget} for his goals. 
    This means his 'safe' spendable balance is actually KES ${spendableBalance.toFixed(2)}. 
    He spends KES ${avgBurn.toFixed(2)} per day and will hit 0 in ${daysLeft} days.
    Give a brief, witty "big brother" financial advice snippet in a Kenyan context. 
    If the spendable balance is negative, be very urgent—he is spending his goal money!`;

    const aiResult = await model.generateContent(prompt);
    const response = await aiResult.response;

    res.status(200).json({
      success: true,
      userName: firstName,
      actualBalance: currentBalance,
      spendableBalance: spendableBalance.toFixed(2),
      reservedForGoals: (totalGoalTarget - totalSavedSoFar).toFixed(2),
      avgDailySpend: avgBurn.toFixed(2),
      daysRemaining: daysLeft,
      predictedExhaustionDate: exhaustionDate.toDateString(),
      aiInsight: response.text(),
    });
  } catch (error) {
    console.error("Forecast Error:", error);
    res
      .status(500)
      .json({ error: "Failed to generate forecast", details: error.message });
  }
};
