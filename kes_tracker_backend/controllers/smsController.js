const { GoogleGenerativeAI } = require("@google/generative-ai");
const Transaction = require("../models/TransactionModel");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// 1. MAIN PARSER (Updated to capture post_balance)
exports.parseAndSaveSMS = async (req, res) => {
  try {
    const { smsText } = req.body;
    const userId = req.user;

    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
    });

    // Updated Prompt to capture balance and Fuliza status
    const prompt = `Analyze this Kenyan M-Pesa SMS: "${smsText}". 
    Extract the following fields into JSON:
    1. transaction_id: The unique M-Pesa code (e.g., RDK25GHT6).
    2. amount: Number only.
    3. merchant: The recipient or sender name. If Paybill/Till, use the Business Name.
    4. category: Contextual category (e.g., Food, Utilities, Transport, Income, Shopping).
    5. type: Strictly "income" or "expense".
    6. post_balance: The "New M-Pesa balance" mentioned at the end (Number only).
    7. is_fuliza: Boolean, true if Fuliza was used.
    Return JSON only.`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Securely extract JSON from AI response
    const jsonString = text.substring(
      text.indexOf("{"),
      text.lastIndexOf("}") + 1,
    );
    const parsedData = JSON.parse(jsonString);

    const rawAmount = parsedData.amount || 0;
    const cleanAmount = parseFloat(String(rawAmount).replace(/[^0-9.]/g, ""));
    const cleanBalance =
      parseFloat(String(parsedData.post_balance).replace(/[^0-9.]/g, "")) ||
      null;
    const merchant = parsedData.merchant || "Unknown";
    const category = parsedData.category || "General";

    const lowerSMS = smsText.toLowerCase();
    let type = (parsedData.type || "expense").toLowerCase();

    const expenseKeywords = [
      "paid",
      "sent",
      "bought",
      "withdraw",
      "paybill",
      "buy goods",
    ];
    const incomeKeywords = ["received", "deposited", "reversed"];

    if (expenseKeywords.some((word) => lowerSMS.includes(word))) {
      type = "expense";
    } else if (incomeKeywords.some((word) => lowerSMS.includes(word))) {
      type = "income";
    }

    // --- ENHANCED CLARIFICATION LOGIC (Preserved) ---
    const isPhoneNumber = /^(07|01|\+254)\d{8}$/.test(
      merchant.replace(/\s/g, ""),
    );

    const isPochi = lowerSMS.includes("pochi la biashara");

    const needsClarification =
      category === "Others" ||
      category === "General" ||
      isPhoneNumber ||
      isPochi ||
      isNaN(cleanAmount);

    // Save to Database (including the new postBalance field)
    const savedTransaction = await Transaction.create({
      userId: userId,
      transactionId: parsedData.transaction_id || parsedData.Transaction_Id,
      amount: cleanAmount,
      merchant: merchant,
      category: category,
      type: type,
      smsRaw: smsText,
      postBalance: cleanBalance, // New field added
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
    res
      .status(500)
      .json({ error: "Processing failed", details: error.message });
  }
};

// 2. FETCH ALL (Preserved)
exports.getAllTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.findAll(req.user);
    res.status(200).json(transactions);
  } catch (error) {
    console.error("Fetch Error:", error);
    res.status(500).json({ error: "Failed to fetch transactions" });
  }
};

// 3. SUMMARY (Preserved)
exports.getFinanceSummary = async (req, res) => {
  try {
    const summary = await Transaction.getSummary(req.user);
    res.status(200).json(summary);
  } catch (error) {
    console.error("Summary Error:", error);
    res.status(500).json({ error: "Failed to calculate summary" });
  }
};

// 4. UPDATE TRANSACTION (Preserved)
exports.updateTransaction = async (req, res) => {
  try {
    const { id } = req.params;
    const { category } = req.body;
    const userId = req.user;

    const updated = await Transaction.update(id, userId, {
      category: category,
      needsClarification: false,
    });

    if (!updated) {
      return res.status(404).json({ error: "Transaction not found" });
    }

    res.status(200).json({
      message: "Transaction updated successfully",
      transaction: updated,
    });
  } catch (error) {
    console.error("Update Error:", error);
    res.status(500).json({ error: "Failed to update transaction" });
  }
};

// 5. PENDING (Preserved)
exports.getPendingClarifications = async (req, res) => {
  try {
    const transactions = await Transaction.findPending(req.user);
    res.status(200).json(transactions);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch pending tasks" });
  }
};

// 6. CATEGORY BREAKDOWN (Preserved)
exports.getCategoryBreakdown = async (req, res) => {
  try {
    const totals = await Transaction.getCategoryTotals(req.user);
    res.status(200).json(totals);
  } catch (error) {
    res.status(500).json({ error: "Failed to calculate breakdown" });
  }
};

// 7. SEARCH (Preserved)
exports.searchTransactions = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ error: "Search term is required" });
    }

    const results = await Transaction.search(req.user, q);
    res.status(200).json(results);
  } catch (error) {
    console.error("Search Error:", error);
    res.status(500).json({ error: "Search failed" });
  }
};

// 8. DATE FILTER (Preserved)
exports.getTransactionsByDate = async (req, res) => {
  try {
    const { start, end } = req.query;

    if (!start || !end) {
      return res
        .status(400)
        .json({ error: "Please provide both start and end dates" });
    }

    const results = await Transaction.filterByDate(req.user, start, end);
    res.status(200).json(results);
  } catch (error) {
    console.error("Date Filter Error:", error);
    res
      .status(500)
      .json({ error: "Failed to fetch transactions for this period" });
  }
};
