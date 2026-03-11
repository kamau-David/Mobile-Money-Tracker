const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    amount: {
      type: Number,
      required: true,
    },

    merchant: {
      type: String,
      required: true,
    },

    category: {
      type: String,
      default: "General",
    },

    type: {
      type: String,
      enum: ["income", "expense"],
    },

    date: {
      type: Date,
      default: Date.now,
    },

    smsRaw: String,
    needs_clarification: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Transaction", transactionSchema);
