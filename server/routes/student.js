const express = require("express");
const router = express.Router();
const { auth, isDriver, isParent } = require("../middleware/login.js");
const { check } = require("express-validator");
const controller = require("../controllers/student_controllers/students.js");
const {
  createStudent,
  getStudentSettings,
  updateStudentSettings,
  getStudentsByParent,
  getStudentByDriver,
  deleteStudentByDriver,
  updateStudentByDriver
} = controller;

router
  .post("/createStudent", auth, isDriver, createStudent)
  .post("/getStudentSettings", auth, isParent, getStudentSettings)
  .post("/updateStudentSettings", auth, isParent, updateStudentSettings)
  .post("/getStudentsByParent", auth, getStudentsByParent)
  .post("/getStudentByDriver", auth, getStudentByDriver)
  .post("/deleteStudentByDriver", auth, deleteStudentByDriver)
  .post("/updateStudentByDriver", auth, updateStudentByDriver);

module.exports = router;
