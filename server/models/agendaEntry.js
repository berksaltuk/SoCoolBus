const mongoose = require("mongoose");

const AgendaEntrySchema = new mongoose.Schema({
  // TODO: will be updated when we add permission related stuff
  payment: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Payment", // If agendaEntry type is payment
  },
  expense: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Expense", // If agendaEntry type is expense
  },
  permission: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Permission", // If agendaEntry type is permission
  },
  sms: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "SMS", // If agendaEntry type is send iban or  ask for payment
  },
  shift: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Shift", // Entry type absence
  },
  mainHeader: {
    type: String,
    required: true,
  },
  summary: {
    type: String,
    required: true,
  },
  detailedDescription: {
    type: String,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  driver: {
    type: String, // to understand whose agendaEntry
    required: true,
  },
  agendaEntryType: {
    type: String,
    enum: [
      "PERMISSION",
      "EXPENSE",
      "PAYMENT",
      "SEND_IBAN",
      "ASK_FOR_PAYMENT",
      "ABSENCE",
      "POSTPONE",
    ],
    required: true,
  },
});

module.exports = AgendaEntry = mongoose.model("AgendaEntry", AgendaEntrySchema);
