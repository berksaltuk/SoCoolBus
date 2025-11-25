const mongoose = require("mongoose");

const NoteSchema = new mongoose.Schema({
  student: {
    // Note for which student
    type: mongoose.Schema.Types.ObjectId,
    ref: "Student",
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  description: {
    type: String,
    required: true,
  },
  noteAdderType: {
    // Who added this note
    type: String,
    enum: ["PARENT", "DRIVER"],
    required: true,
  },
  driverPhone: {
    // Which driver will see this note.
    type: String,
    required: true,
  },
});

module.exports = Note = mongoose.model("Note", NoteSchema);
