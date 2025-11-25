const mongoose = require("mongoose");

const AnnouncementSchema = new mongoose.Schema({
  description: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  publishedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  date: {
    type: Date,
    required: true,
  },
});

module.exports = Announcement = mongoose.model(
  "Announcement",
  AnnouncementSchema
);
