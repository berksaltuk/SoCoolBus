const mongoose = require("mongoose");

const DocumentSchema = new mongoose.Schema({
  documentType: {
    type: String,
    enum: [
      "REGISTRATION",
      "LICENSE",
      "PSYCHOTECHNIC",
      "IDENTIFICATION",
      "SRC",
      "INSURANCE",
      "TUVTURK",
    ],
  },
  fileName: {
    type: String,
    required: true,
  },
  driverPhone: {
    type: String,
    required: true,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
  isRejected: {
    type: Boolean,
    default: false,
  },
  documentName: {
    type: String,
  },
  documentNote: {
    type: String,
  },
  documentDate: {
    type: Date,
  },
});

module.exports = Document = mongoose.model("Document", DocumentSchema);
