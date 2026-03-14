const Bill = require("../models/BillModel");
const Transaction = require("../models/TransactionModel");
const { pool } = require("../config/db");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// 1. REMINDERS LOGIC
exports.getUpcomingReminders = async (req, res) => {
  try {
    const userId = req.user;
    const today = new Date();
    const currentDay = today.getDate();

    const bills = await Bill.findByUser(userId);
    let reminders = [];

    // Use the exact same initialization logic from your smsController
    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
    });

    for (let bill of bills) {
      if (
        bill.due_date_day > currentDay &&
        bill.due_date_day <= currentDay + 3
      ) {
        const prompt = `David has a bill for ${bill.merchant_name} (KES ${bill.amount_expected}) due on the ${bill.due_date_day}th. 
        It's now the ${currentDay}th. Write a short, friendly Kenyan-style reminder. 
        Ask about his plans for this payment. Be supportive, use a touch of Sheng or local context.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        reminders.push({
          merchant: bill.merchant_name,
          amount: bill.amount_expected,
          dueDate: bill.due_date_day,
          aiMessage: text,
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

// 2. FORECAST LOGIC
exports.getForecast = async (req, res) => {
  try {
    const userId = req.user;
    const summary = await Transaction.getSummary(userId);
    const currentBalance = summary.currentBalance;

    const burnRateQuery = `
      SELECT AVG(daily_total) as avg_burn
      FROM (
        SELECT SUM(amount) as daily_total
        FROM transactions
        WHERE user_id = $1 AND type = 'expense' 
        AND created_at > NOW() - INTERVAL '7 days'
        GROUP BY DATE(current_date)
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

    const prompt = `David has KES ${currentBalance} left. He spends an average of KES ${avgBurn.toFixed(2)} per day. 
    He will likely run out of money in ${daysLeft} days (around ${exhaustionDate.toDateString()}).
    Give a brief, witty "big brother" financial advice snippet in a Kenyan context. 
    If the date is very soon, be more urgent.`;

    const aiResult = await model.generateContent(prompt);
    const response = await aiResult.response;

    res.status(200).json({
      success: true,
      currentBalance,
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
