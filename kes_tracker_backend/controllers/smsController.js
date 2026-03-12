const { GoogleGenerativeAI } = require("@google/generative-ai");
const Transaction = require("../models/TransactionModel");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.parseAndSaveSMS = async (req, res) => {
  try {
    const { smsText } = req.body;

    // 1. Get the userId from the request (attached by your Auth Middleware)
    const userId = req.user;

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
    });

    const prompt = `Analyze this M-Pesa SMS: "${smsText}". 
    Extract the following fields into JSON:
    1. transaction_id: The unique M-Pesa code (e.g., RDK25GHT6).
    2. amount: Number only.
    3. merchant: Sender name if money received, receiver name if money paid.
    4. category: Spending/Income category.
    5. type: Strictly "income" if money is received, "expense" if money is paid or sent.
    Return JSON only.`;

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
    const rawType = (parsedData.type || "expense").toLowerCase();
    const type = rawType === "income" ? "income" : "expense";

    const needsClarification =
      category === "Others" || merchant.includes("07") || isNaN(cleanAmount);

    // 2. Pass the userId to the Transaction model so it's saved in the DB
    const savedTransaction = await Transaction.create({
      userId: userId, // <--- New Field
      transactionId: parsedData.transaction_id || parsedData.Transaction_Id,
      amount: cleanAmount,
      merchant: merchant,
      category: category,
      type: type,
      smsRaw: smsText,
      needsClarification: needsClarification,
    });

    if (!savedTransaction) {
      return res.status(409).json({
        message: "Transaction already exists",
        transactionId: parsedData.transaction_id,
      });
    }

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
    // 3. Only fetch transactions for the logged-in user
    const transactions = await Transaction.findAll(req.user);
    res.status(200).json(transactions);
  } catch (error) {
    console.error("Fetch Error:", error);
    res.status(500).json({ error: "Failed to fetch transactions" });
  }
};

exports.getFinanceSummary = async (req, res) => {
  try {
    // 4. Calculate summary specifically for this user
    const summary = await Transaction.getSummary(req.user);
    res.status(200).json(summary);
  } catch (error) {
    console.error("Summary Error:", error);
    res.status(500).json({ error: "Failed to calculate summary" });
  }
};
