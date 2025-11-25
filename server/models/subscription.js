const mongoose = require("mongoose");

const SubscriptionSchema = new mongoose.Schema({
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
  timeIsUp: {
    type: Boolean,
    default: false,
  },
  lastChecked: {
    type: Date,
    default: Date.now,
  },
});

module.exports = Subscription = mongoose.model(
  "Subscription",
  SubscriptionSchema
);
