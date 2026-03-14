const Transaction = require("../models/TransactionModel");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.getUpcomingReminders = async (req, res) => {
  try {
    const userId = req.user;
    const today = new Date();
    const currentDay = today.getDate();

    // 1. Fetch "Expected" bills from the DB (e.g., Rent due on the 5th)
    // For now, let's assume we have a list.
    // In a real app, David would have tagged a past transaction as "Recurring".
    const bills = await pool.query("SELECT * FROM bills WHERE user_id = $1", [
      userId,
    ]);

    let reminders = [];

    for (let bill of bills.rows) {
      // Check if the bill is due in the next 3 days and hasn't been paid
      if (
        bill.due_date_day > currentDay &&
        bill.due_date_day <= currentDay + 3
      ) {
        // Use Gemini to craft a "Human" message
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        const prompt = `David has a recurring bill for ${bill.merchant_name} (KES ${bill.amount_expected}) due on the ${bill.due_date_day}th. 
        It's now the ${currentDay}th and he hasn't paid it yet. 
        Write a very friendly, supportive Kenyan-style reminder (mentioning M-Pesa context if relevant) asking what his plans are. 
        Keep it short and helpful, not robotic.`;

        const result = await model.generateContent(prompt);
        reminders.push({
          merchant: bill.merchant_name,
          dueDate: bill.due_date_day,
          aiMessage: result.response.text(),
        });
      }
    }

    res.status(200).json({ success: true, reminders });
  } catch (error) {
    res.status(500).json({ error: "Failed to generate reminders" });
  }
};
