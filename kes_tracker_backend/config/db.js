const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "kes-tracker",
  password: process.env.DB_PASSWORD,
  port: 5432,
});

const connectDB = async () => {
  try {
    await pool.query("SELECT NOW()");
    console.log("✅ PostgreSQL Connected Locally!");
  } catch (err) {
    console.error("❌ Postgres Connection Error:", err.message);
  }
};

module.exports = { pool, connectDB };
