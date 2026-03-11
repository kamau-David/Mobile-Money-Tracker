require("dotenv").config();
const express = require("express");
const { connectDB } = require("./config/db");
const smsRoutes = require("./routes/smsRoutes"); // 1. Clean import

const app = express();

// Initialize Database
connectDB();

// Middleware
app.use(express.json());

// Basic Health Check (Optional but helpful)
app.get("/", (req, res) => {
  res.send("🚀 KES Tracker Backend is Running!");
});

// 2. Use the imported routes
app.use("/api", smsRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
