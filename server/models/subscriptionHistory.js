const mongoose = require("mongoose");

const SubscriptionHistorySchema = new mongoose.Schema({
  driver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Driver",
    required: true,
  },
  starts: {
    type: Date,
    required: true,
  },
  ends: {
    type: Date,
    required: true,
  },
  maxSchoolNumber: {
    type: Number,
    required: true,
  },
  subscriptionType: {
    type: String,
    enum: ["TRIAL", "PAID"],
  },
  subscriptionFee: {
    type: Number,
    required: true,
  },
  lengthInMonths: {
    type: Number,
  },
});

module.exports = SubscriptionHistory = mongoose.model(
  "SubscriptionHistory",
  SubscriptionHistorySchema
);
