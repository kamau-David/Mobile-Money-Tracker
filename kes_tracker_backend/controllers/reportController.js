const Transaction = require("../models/TransactionModel");
const User = require("../models/UserModel");
const PDFDocument = require("pdfkit");

exports.generatePDF = async (req, res) => {
  try {
    const userId = req.user;
    const { category, start, end, txId } = req.query;

    const trendStart =
      start ||
      new Date(new Date().setDate(new Date().getDate() - 30))
        .toISOString()
        .split("T")[0];
    const trendEnd = end || new Date().toISOString().split("T")[0];

    // 1. Fetch Data
    const user = await User.findById(userId);
    const transactions = await Transaction.findForReport(userId, {
      category,
      startDate: start,
      endDate: end,
      transactionId: txId,
    });
    const trends = await Transaction.getDailyTrends(
      userId,
      trendStart,
      trendEnd,
    );

    if (!user) return res.status(404).json({ error: "User not found" });
    if (!transactions || transactions.length === 0)
      return res.status(404).json({ error: "No transactions found" });

    // 2. Initialize PDF Document (Using Standard Fonts)
    const doc = new PDFDocument({ margin: 50, bufferPages: true });

    // 3. Setup Response Stream
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename=KES_Tracker_Report.pdf`,
    );
    doc.pipe(res);

    // --- HEADER & BRANDING ---
    doc
      .font("Helvetica-Bold")
      .fontSize(22)
      .fillColor("#2E7D32")
      .text("KES TRACKER", { align: "right" });
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor("#757575")
      .text("Professional Financial Statement", { align: "right" });
    doc.moveDown();

    // --- USER DETAILS ---
    doc
      .fontSize(12)
      .fillColor("#000")
      .font("Helvetica-Bold")
      .text(`Account Holder: ${user.full_name}`);
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor("#424242")
      .text(`Phone Number: ${user.phone_number}`);
    doc.text(`Report Period: ${start || "Beginning"} - ${end || "Present"}`);
    doc.text(`Generated: ${new Date().toLocaleString("en-GB")}`);
    doc.moveDown();

    // --- SUMMARY BOX ---
    const totalIncome = transactions
      .filter((t) => t.type === "income")
      .reduce((s, t) => s + parseFloat(t.amount), 0);
    const totalExpense = transactions
      .filter((t) => t.type === "expense")
      .reduce((s, t) => s + parseFloat(t.amount), 0);
    const balance = totalIncome - totalExpense;

    const boxTop = doc.y;
    doc.rect(50, boxTop, 500, 70).fillAndStroke("#f9f9f9", "#2E7D32");
    doc
      .fillColor("#2E7D32")
      .font("Helvetica-Bold")
      .fontSize(12)
      .text("Report Summary", 70, boxTop + 10);
    doc
      .fillColor("#000")
      .font("Helvetica")
      .fontSize(10)
      .text(`Income: KES ${totalIncome.toLocaleString()}`, 70, boxTop + 30);
    doc.text(`Expense: KES ${totalExpense.toLocaleString()}`, 200, boxTop + 30);

    const balanceColor = balance >= 0 ? "#1B5E20" : "#C62828";
    doc
      .fillColor(balanceColor)
      .font("Helvetica-Bold")
      .text(`Net Cash Flow: KES ${balance.toLocaleString()}`, 70, boxTop + 50);
    doc.moveDown(4);

    // --- CHART SECTION ---
    if (trends.length > 1) {
      doc
        .font("Helvetica-Bold")
        .fontSize(12)
        .fillColor("#2E7D32")
        .text("Daily Spending Trends", { underline: true });
      doc.moveDown(0.5);
      const chartHeight = 80;
      const chartWidth = 450;
      const startX = 70;
      const startY = doc.y + chartHeight;
      const maxVal = Math.max(
        ...trends.map((d) =>
          Math.max(parseFloat(d.income), parseFloat(d.expense)),
        ),
        100,
      );

      doc
        .moveTo(startX, startY)
        .lineTo(startX + chartWidth, startY)
        .strokeColor("#EEEEEE")
        .lineWidth(1)
        .stroke();

      // Expense Line (Red)
      doc.strokeColor("#C62828").lineWidth(2);
      trends.forEach((d, i) => {
        const x = startX + i * (chartWidth / (trends.length - 1));
        const y = startY - (parseFloat(d.expense) / maxVal) * chartHeight;
        i === 0 ? doc.moveTo(x, y) : doc.lineTo(x, y);
      });
      doc.stroke();

      // Income Line (Green)
      doc.strokeColor("#2E7D32").lineWidth(2);
      trends.forEach((d, i) => {
        const x = startX + i * (chartWidth / (trends.length - 1));
        const y = startY - (parseFloat(d.income) / maxVal) * chartHeight;
        i === 0 ? doc.moveTo(x, y) : doc.lineTo(x, y);
      });
      doc.stroke();
      doc.moveDown(7);
    }

    // --- TRANSACTION TABLE ---
    doc
      .font("Helvetica-Bold")
      .fillColor("#000")
      .fontSize(12)
      .text("Transaction History", { underline: true });
    doc.moveDown(0.5);
    const tableTop = doc.y;
    const rowHeight = 25;

    doc.rect(50, tableTop, 500, rowHeight).fill("#E8F5E9");
    doc.fillColor("#2E7D32").font("Helvetica-Bold").fontSize(10);
    doc.text("Date", 60, tableTop + 7);
    doc.text("Merchant/Description", 140, tableTop + 7);
    doc.text("Category", 330, tableTop + 7);
    doc.text("Amount (KES)", 440, tableTop + 7, { width: 100, align: "right" });

    let currentY = tableTop + rowHeight;

    transactions.forEach((tx, index) => {
      if (currentY > 700) {
        doc.addPage();
        currentY = 50;
      }
      if (index % 2 !== 0) {
        doc.rect(50, currentY, 500, rowHeight).fill("#fbfbfb");
      }

      doc.font("Helvetica").fontSize(9).fillColor("#000");
      const isInc = tx.type === "income";
      const displayAmount = isInc
        ? `+${parseFloat(tx.amount).toLocaleString()}`
        : `-${parseFloat(tx.amount).toLocaleString()}`;

      doc.text(
        new Date(tx.created_at).toLocaleDateString("en-GB"),
        60,
        currentY + 7,
      );
      doc.text(tx.merchant.substring(0, 30), 140, currentY + 7);
      doc.text(tx.category || "General", 330, currentY + 7);
      doc
        .fillColor(isInc ? "#2E7D32" : "#C62828")
        .font("Helvetica-Bold")
        .text(displayAmount, 440, currentY + 7, { width: 100, align: "right" });

      doc
        .moveTo(50, currentY + rowHeight)
        .lineTo(550, currentY + rowHeight)
        .strokeColor("#EEEEEE")
        .lineWidth(0.5)
        .stroke();
      currentY += rowHeight;
    });

    doc
      .rect(50, tableTop, 500, currentY - tableTop)
      .strokeColor("#2E7D32")
      .lineWidth(1)
      .stroke();

    // --- FOOTER ---
    const range = doc.bufferedPageRange();
    for (let i = range.start; i < range.start + range.count; i++) {
      doc.switchToPage(i);
      doc
        .font("Helvetica")
        .fontSize(8)
        .fillColor("gray")
        .text(
          `Page ${i + 1} of ${range.count} | KES Tracker Statements`,
          50,
          750,
          { align: "center" },
        );
    }

    doc.end();
  } catch (error) {
    console.error("PDF Error:", error);
    if (!res.headersSent) {
      res.status(500).json({ error: "Generation failed" });
    }
  }
};

exports.getDashboardStats = async (req, res) => {
  try {
    const userId = req.user; // Provided by your 'protect' middleware

    const categoryStats = await Transaction.getCategoryStats(userId);

    // Calculate total spending
    const totalSpent = categoryStats.reduce(
      (sum, item) => sum + parseFloat(item.total_amount),
      0,
    );

    res.json({
      success: true,
      totalSpent,
      breakdown: categoryStats,
      message:
        categoryStats.length > 0
          ? `You spent the most on ${categoryStats[0].category} this month.`
          : "No expenses found for this period.",
    });
  } catch (error) {
    console.error("Stats Error:", error);
    res.status(500).json({ error: "Could not calculate spending stats" });
  }
};
