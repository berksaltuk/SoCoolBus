const mongoose = require("mongoose");

const SchoolBusSchema = new mongoose.Schema({
  /**company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Company",
  },**/
  plate: {
    type: String,
    required: true,
    unique: true,
  },
  busModel: {
    type: String,
    required: false,
  },
  muayeneStarts: {
    type: Date,
    required: false,
  },
  muayeneEnds: {
    type: Date,
    required: false,
  },
  sigortaStarts: {
    type: Date,
    required: false,
  },
  sigortaEnds: {
    type: Date,
    required: false,
  },
  companyToken: {
    type: String, // Default is "FREE" if the driver is a free lancer :D
  },
  seatCount: {
    type: Number,
    required: true,
  },
  secondaryUsers: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "SecondaryUser",
    },
  ],
  students: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
    },
  ],
});

module.exports = SchoolBus = mongoose.model("SchoolBus", SchoolBusSchema);
