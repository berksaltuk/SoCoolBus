const mongoose = require("mongoose");

const ShiftScheduleSchema = new mongoose.Schema({
  morningEntranceCompletion: {
    type: Boolean,
    default: false,
  },
  morningEntranceStarted: {
    type: Boolean,
    default: false,
  },
  morningEntranceCompletionTime: {
    type: Date,
  },
  noonEntranceCompletion: {
    type: Boolean,
    default: false,
  },
  noonEntranceStarted: {
    type: Boolean,
    default: false,
  },
  noonEntranceCompletionTime: {
    type: Date,
  },
  noonExitCompletion: {
    type: Boolean,
    default: false,
  },
  noonExitStarted: {
    type: Boolean,
    default: false,
  },
  noonExitCompletionTime: {
    type: Date,
  },
  eveningExitCompletion: {
    type: Boolean,
    default: false,
  },
  eveningExitStarted: {
    type: Boolean,
    default: false,
  },
  eveningExitCompletionTime: {
    type: Date,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  driver: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
  school: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
}); // I do not know mmaaann, this looks sooo cursed but we are just tryinnnnn

module.exports = ShiftSchedule = mongoose.model(
  "ShiftSchedule",
  ShiftScheduleSchema
);
