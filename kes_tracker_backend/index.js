require("dotenv").config();
const express = require("express");
const { connectDB } = require("./config/db");
const cors = require("cors");
const smsRoutes = require("./routes/smsRoutes");
const authRoutes = require("./routes/authRoutes");
const reportRoutes = require("./routes/reportRoutes");
const insightRoutes = require("./routes/insightRoutes");

const app = express();

// Initializing Database
connectDB();

// Middlewares
app.use(express.json());
app.use(cors());
app.use("/api/auth", authRoutes);
app.use("/api", smsRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/insights", insightRoutes);

app.get("/", (req, res) => {
  res.send("🚀 KES Tracker Backend is Running!");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
