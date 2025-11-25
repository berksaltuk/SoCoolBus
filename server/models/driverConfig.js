const mongoose = require("mongoose");

const DriverConfigSchema = new mongoose.Schema({
  driverPhone: {
    type: String,
    required: true,
  },
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "School",
  },
  dueDate: {
    type: Number,
    required: true,
  },
});

module.exports = DriverConfig = mongoose.model(
  "DriverConfig",
  DriverConfigSchema
);
