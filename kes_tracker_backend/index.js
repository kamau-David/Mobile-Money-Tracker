require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const smsRoutes = require("./routes/smsRoutes");

const app = express();
connectDB(); // Initialize Database

app.use(express.json());

// Routes
app.use("/api", require("./routes/smsRoutes"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
