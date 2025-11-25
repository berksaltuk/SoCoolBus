const mongoose = require("mongoose");

const StudentSchema = new mongoose.Schema({
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "School",
    required: true,
  },
  parent: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Parent",
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  secondPhoneNumber: {
    type: String,
  },
  directionPreference: {
    //çift yön 1 tek yön sabah 2  tek yön akşam 3 (sadece sabah sadece akşam kullanıcak veya ikisini de kullanacak seçeneği)
    type: Number,
    required: true,
  },
  paymentPreference: {
    //ödeme şekli 0: aylık 1: yıllık
    type: Number,
    required: true,
  },
  whogondothePayment: {
    // ödeme yapan 0: veli öğrenci 1: kurum 2: okul
    type: Number,
    required: true,
  },
  schoolStartTime: {
    //sabahçı::0 öğleci:1 tam gün:2
    type: Number,
    required: true,
  },
  orderByDriverH2S: {
    //order given by driver from home to school
    type: Number,
    default: 1,
  },
  orderByDriverS2H: {
    //order given by driver from school to home
    type: Number,
    default: 1,
  },
  class: {
    type: Number,
  },
  notificationPreference: {
    type: Boolean,
    default: false,
  },
  callPreference: {
    type: Boolean,
    default: false,
  },
  smsPreference: {
    type: Boolean,
    default: false,
  },
  active: {
    type: Boolean,
    default: true,
  },
  currentShift: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Shift",
  },
  onShift: {
    type: Boolean,
    default: false,
  },
});

module.exports = Student = mongoose.model("Student", StudentSchema);
