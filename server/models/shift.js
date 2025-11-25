const mongoose = require("mongoose");

const ShiftSchema = new mongoose.Schema({
  startTime: {
    type: Date,
    default: Date.now,
  },
  endTime: {
    type: Date,
  },
  lastStudentTakenAt: {
    type: Date,
  },
  driverPhone: {
    type: String,
    required: true,
  },
  shiftName: {
    type: String,
    enum: ["Sabah Giriş", "Öğlen Giriş", "Öğlen Çıkış", "Akşam Çıkış"],
    required: true,
  },
  students: [
    {
      _id: false,
      student: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Student",
      },
      getOnTime: {
        type: Date,
      },
      getOffTime: {
        type: Date,
      },
      attendanceStatus: {
        type: Number,
        enum: [100, 200, 201, 300, 301, 400, 401, 500, 501],
        default: 100,
      },
      attendanceDescription: {
        type: String,
        enum: [
          "Beklemede",
          "Zamanında Alındı", // H2S
          "Beklendi Alındı", // H2S
          "İzinli", // Okulda Kalacak - Velisi Alacak
          "Beklendi Alınmadı", // H2S
          "Servise Bindi", // S2H
          "Servise Binmedi", // S2H
          "Eve Bırakıldı", // S2H
          "Konuma Bırakıldı", // S2H ama gerek var mı bilmiyorum
        ],
        default: "Beklemede",
      },
      studentsOrder: {
        type: Number,
      },
    },
  ],
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "School",
  },
  bus: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "SchoolBus",
  },
  currentLocation: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Location",
  },
  driver: {
    type: mongoose.Schema.Types.ObjectId,
    required: false,
    ref: "Driver",
  },
  lateEntrance: {
    type: Boolean,
  },
});

module.exports = Shift = mongoose.model("Shift", ShiftSchema);
