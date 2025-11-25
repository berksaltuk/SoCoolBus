const mongoose = require("mongoose");

const PaymentSchema = new mongoose.Schema({
  paidAmount: {
    type: Number,
    required: true,
  },
  leftAmount: {
    type: Number,
    required: true,
  },
  paidTo: {
    type: String, // phone,
  },
  paidBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Student",
  },
  lastUpdate: {
    type: Date,
    default: Date.now(),
  },
  dueDate: {
    type: Date,
  },
  originalDueDate: {
    type: Date,
  },
  statusChange: {
    type: Date,
    default: Date.now(),
  },
  paymentStatus: {
    type: String,
    enum: ["unpaid", "paid", "late", "postponed"],
    default: "unpaid",
  },
  installment: {
    //bu kaçıncı taksit
    type: Number,
    required: true,
  },
  totalInstallment: {
    //sevise kaç ay yazıldı
    type: Number,
    required: true,
  },
  additional: {
    type: Boolean,
    default: false
  },
  originalAmount: {
    type: Number,
    required: true,
  }
});

module.exports = Payment = mongoose.model("Payment", PaymentSchema);
