const express = require("express");
const router = express.Router();
const { auth, isDriver } = require("../middleware/login.js");
const controller = require("../controllers/shift_controllers/shift.js");
const {
  createShift,
  getShift,
  createShiftSchedule,
  updateStudentStatus,
  endShift,
} = controller;

router
  .post("/createShift", auth, isDriver, createShift)
  .post("/getShift", auth, isDriver, getShift)
  .post("/createShiftSchedule", auth, isDriver, createShiftSchedule)
  .post("/updateStudentStatus", auth, isDriver, updateStudentStatus)
  .post("/endShift", auth, isDriver, endShift);
module.exports = router;
