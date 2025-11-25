const mongoose = require("mongoose");
const PermissionSchema = new mongoose.Schema({
  student: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Student",
  },
  permissionGivenBy: {
    //parent or idareci
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  date: {
    type: Date,
    default: Date.now,
  },
  shiftName: [
    {
      type: String,
      enum: ["Sabah Giriş", "Öğlen Giriş", "Öğlen Çıkış", "Akşam Çıkış"],
      required: true,
    },
  ],
});

module.exports = Permission = mongoose.model("Permission", PermissionSchema);
