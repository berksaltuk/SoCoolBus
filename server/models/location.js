const mongoose = require("mongoose");

const LocationSchema = new mongoose.Schema({
  lat: {
    type: Number,
    required: true,
  },
  lon: {
    type: Number,
    required: true,
  },
  shift: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Shift",
    required: true,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = Location = mongoose.model("Location", LocationSchema);
