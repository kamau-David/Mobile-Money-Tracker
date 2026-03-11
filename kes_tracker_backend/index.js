const express = require("express");
const { GoogleGenAI } = require("@google/genai");
require("dotenv").config();

const app = express();
app.use(express.json());

// FIXED: Added apiVersion: 'v1' and using the newer 2.5 model
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
  httpOptions: { apiVersion: "v1" },
});

// Auditor Logic
function auditTransaction(data) {
  const vagueCategories = ["General", "Others", "Unknown", "Transfer"];
  const isPhoneNumber = /^(\+254|0|7|1)\d{7,12}$/.test(
    data.merchant.replace(/\s/g, ""),
  );

  if (vagueCategories.includes(data.category) || isPhoneNumber) {
    return {
      ...data,
      needs_clarification: true,
      prompt_question: `What was this KES ${data.amount} for?`,
    };
  }
  return { ...data, needs_clarification: false };
}

app.post("/api/parse-sms", async (req, res) => {
  try {
    const { smsText } = req.body;

    // FIXED: Using 'gemini-2.5-flash' which is the 2026 stable workhorse
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: `
                Extract Amount, Merchant, Category, and Type (income/expense) from this Kenyan M-Pesa SMS: "${smsText}".
                Return ONLY a JSON object. 
                Example: {"amount": 500, "merchant": "Naivas", "category": "Food", "type": "expense"}
            `,
    });

    let aiText = response.text;
    const start = aiText.indexOf("{");
    const end = aiText.lastIndexOf("}") + 1;
    const jsonString = aiText.substring(start, end);

    let parsedData = JSON.parse(jsonString);
    res.json(auditTransaction(parsedData));
  } catch (error) {
    console.error("Detailed Error:", error);
    res
      .status(500)
      .json({ error: "AI connection failed. Check model availability." });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 KES Tracker Server Online at http://localhost:${PORT}`);
});
