const { GoogleGenerativeAI } = require("@google/generative-ai");
const { pool } = require("../config/db");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.parseAndSaveSMS = async (req, res) => {
  try {
    const { smsText } = req.body;

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-2.5-flash",
    });

    const prompt = `Extract Amount (number only), Merchant, Category, and Type (income/expense) from: "${smsText}". Return JSON only.`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    const jsonString = text.substring(
      text.indexOf("{"),
      text.lastIndexOf("}") + 1,
    );
    const parsedData = JSON.parse(jsonString);

    const rawAmount = parsedData.amount || parsedData.Amount || 0;
    const cleanAmount = parseFloat(String(rawAmount).replace(/[^0-9.]/g, ""));

    const merchant = parsedData.merchant || parsedData.Merchant || "Unknown";
    const category = parsedData.category || "General";
    const type = (parsedData.type || "expense").toLowerCase();

    const needsClarification =
      category === "Others" || merchant.includes("07") || isNaN(cleanAmount);

    const queryText = `
      INSERT INTO transactions (amount, merchant, category, type, sms_raw, needs_clarification)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *;
    `;

    const values = [
      cleanAmount,
      merchant,
      category,
      type,
      smsText,
      needsClarification,
    ];

    const dbResult = await pool.query(queryText, values);

    res.status(201).json(dbResult.rows[0]);
  } catch (error) {
    console.error("Controller Error:", error);
    res.status(500).json({
      error: "Processing failed",
      details: error.message,
    });
  }
};
