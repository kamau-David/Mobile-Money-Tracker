const Bill = require("../models/BillModel"); // Use the model we just made!
const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.getUpcomingReminders = async (req, res) => {
  try {
    const userId = req.user;
    const today = new Date();
    const currentDay = today.getDate();

    // 1. Fetch "Expected" bills using our new Bill Model
    const bills = await Bill.findByUser(userId);

    let reminders = [];

    for (let bill of bills) {
      // Logic: If due in the next 3 days
      if (
        bill.due_date_day > currentDay &&
        bill.due_date_day <= currentDay + 3
      ) {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        // Custom Prompt for a "Financial Coach" feel
        const prompt = `David has a bill for ${bill.merchant_name} (KES ${bill.amount_expected}) due on the ${bill.due_date_day}th. 
        It's the ${currentDay}th. Write a short, friendly Kenyan-style reminder. 
        Ask about his plans for this payment. Be supportive, use a touch of Sheng or local context if natural.`;

        const result = await model.generateContent(prompt);

        reminders.push({
          merchant: bill.merchant_name,
          amount: bill.amount_expected,
          dueDate: bill.due_date_day,
          aiMessage: result.response.text(),
        });
      }
    }

    res.status(200).json({ success: true, reminders });
  } catch (error) {
    console.error("Insight Error:", error);
    res.status(500).json({ error: "Failed to generate reminders" });
  }
};
