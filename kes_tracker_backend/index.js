const express = require("express");
const { GoogleGenAI } = require("@google/genai");
const PDFDocument = require("pdfkit");
const fs = require("fs");
const moment = require("moment");
require("dotenv").config();

const app = express();
app.use(express.json());

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
  httpOptions: { apiVersion: "v1" },
});

// --- PHASE 2: THE AUDITOR LOGIC ---
function auditTransaction(data) {
  const vagueCategories = ["General", "Others", "Unknown", "Transfer"];
  const isPhoneNumber = /^(\+254|0|7|1)\d{7,12}$/.test(
    data.merchant.replace(/\s/g, ""),
  );

  if (vagueCategories.includes(data.category) || isPhoneNumber) {
    return { ...data, needs_clarification: true, status: "flagged" };
  }
  return { ...data, needs_clarification: false, status: "verified" };
}

// --- ROUTE 1: PARSE SMS ---
app.post("/api/parse-sms", async (req, res) => {
  try {
    const { smsText } = req.body;
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: `Extract Amount, Merchant, Category, and Type (income/expense) from: "${smsText}". Return ONLY JSON.`,
    });

    let aiText = response.text;
    const jsonString = aiText.substring(
      aiText.indexOf("{"),
      aiText.lastIndexOf("}") + 1,
    );
    let parsedData = JSON.parse(jsonString);

    res.json(auditTransaction(parsedData));
  } catch (error) {
    res.status(500).json({ error: "AI Parsing failed" });
  }
});

// --- ROUTE 2: GENERATE FILTERED REPORT (Daily/Weekly/Monthly) ---
app.post("/api/generate-report", (req, res) => {
  const { timeframe, categoryFilter, transactions } = req.body;

  // 1. Filter by Timeframe
  const now = moment();
  let filtered = transactions.filter((t) => {
    const transDate = moment(t.date);
    if (timeframe === "daily") return transDate.isSame(now, "day");
    if (timeframe === "weekly")
      return transDate.isAfter(now.clone().subtract(7, "days"));
    if (timeframe === "monthly") return transDate.isSame(now, "month");
    return true;
  });

  // 2. Filter by Category
  if (categoryFilter && categoryFilter !== "all") {
    filtered = filtered.filter(
      (t) => t.category.toLowerCase() === categoryFilter.toLowerCase(),
    );
  }

  // 3. Generate PDF
  const doc = new PDFDocument();
  const fileName = `Report_${timeframe}_${categoryFilter}.pdf`;
  const stream = fs.createWriteStream(fileName);
  doc.pipe(stream);

  doc.fontSize(20).text("KES Tracker Financial Report", { align: "center" });
  doc
    .fontSize(10)
    .text(`Generated on: ${now.format("LLLL")}`, { align: "center" });
  doc.moveDown();

  doc.fontSize(12).text(`Timeframe: ${timeframe} | Filter: ${categoryFilter}`);
  doc.text("------------------------------------------------------------");

  let total = 0;
  filtered.forEach((t) => {
    doc.text(`${t.date} | ${t.merchant} | KES ${t.amount} (${t.category})`);
    total += Number(t.amount);
  });

  doc.moveDown();
  doc.fontSize(14).text(`TOTAL: KES ${total}`, { bold: true });
  doc.end();

  stream.on("finish", () => {
    res.json({
      message: "PDF Created",
      file: fileName,
      total_items: filtered.length,
    });
  });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
