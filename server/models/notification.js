const mongoose = require("mongoose");

const NotificationSchema = new mongoose.Schema({
  content: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  title: {
    type: String,
  },
  sentBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  sentTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  notificationType: {
    type: String,
    enum: ["SMS", "App", "Call"],
  },
});

module.exports = Notification = mongoose.model(
  "Notification",
  NotificationSchema
);
