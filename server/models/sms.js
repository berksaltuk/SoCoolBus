const mongoose = require("mongoose");

const SMSSchema = new mongoose.Schema({
  from: {
    type: String, // phone,
  },
  to: {
    type: String,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  smsSent: {
    type: Boolean,
  },
  msg: {
    type: String,
    required: true,
  },
  smsType: {
    type: String,
  },
});

module.exports = SMS = mongoose.model("SMS", SMSSchema);
