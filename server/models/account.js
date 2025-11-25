const mongoose = require("mongoose");

const AccountSchema = new mongoose.Schema({
  accountName: {
    required: true,
    type: String,
  },
  bankName: {
    type: String,
  },
  receiver: {
    type: String,
    required: true,
  },
  iban: {
    required: true,
    type: String,
  },
  phone: {
    //to understand which drivers' Accounts they are
    type: String,
    required: true,
  },
});

module.exports = Account = mongoose.model("Account", AccountSchema);
