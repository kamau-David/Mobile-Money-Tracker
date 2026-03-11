const { GoogleGenerativeAI } = require("@google/generative-ai");
const Transaction = require("../models/TransactionModel");

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

    const savedTransaction = await Transaction.create({
      amount: cleanAmount,
      merchant: merchant,
      category: category,
      type: type,
      smsRaw: smsText,
      needsClarification: needsClarification,
    });

    res.status(201).json(savedTransaction);
  } catch (error) {
    console.error("Controller Error:", error);
    res.status(500).json({
      error: "Processing failed",
      details: error.message,
    });
  }
};

exports.getAllTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.findAll();
    res.status(200).json(transactions);
  } catch (error) {
    console.error("Fetch Error:", error);
    res.status(500).json({ error: "Failed to fetch transactions" });
  }
};

exports.getFinanceSummary = async (req, res) => {
  try {
    const summary = await Transaction.getSummary();
    res.status(200).json(summary);
  } catch (error) {
    console.error("Summary Error:", error);
    res.status(500).json({ error: "Failed to calculate summary" });
  }
};
