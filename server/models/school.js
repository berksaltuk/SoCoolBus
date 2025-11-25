const mongoose = require("mongoose");

const SchoolSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  schoolType: [
    {
      type: String,
      required: true,
    },
  ],
  shiftCount: {
    type: Number,
    required: true,
  },
  serviceDays: [
    {
      type: String,
      enum: [
        "Pazartesi",
        "Salı",
        "Çarşamba",
        "Perşembe",
        "Cuma",
        "Cumartesi",
        "Pazar",
      ],
      required: false,
    },
  ],
  firstEntranceTime: {
    type: String,
    required: true,
  },
  firstExitTime: {
    type: String,
    required: true,
  },
  secondEntranceTime: {
    type: String,
  },
  secondExitTime: {
    type: String,
  },
  serviceTimeInMonths: {
    type: Number,
    default: 9,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
  whoAddedSchoolPhone: {
    type: String,
  },
});

const School = mongoose.model("School", SchoolSchema);
module.exports = School;
