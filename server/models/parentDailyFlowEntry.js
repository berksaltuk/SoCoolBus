const mongoose = require("mongoose");

const ParentDailyFlowEntrySchema = new mongoose.Schema({
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
  student: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Student",
  },
  parent: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Parent",
  },
  entryType: {
    type: String,
    enum: ["payment", "shift"],
  },
  amount: {
    type: Number,
  },
});

module.exports = ParentDailyFlowEntry = mongoose.model(
  "ParentDailyFlowEntry",
  ParentDailyFlowEntrySchema
);
