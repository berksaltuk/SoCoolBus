const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const { check } = require("express-validator");
const controller = require("../controllers/school_controllers/schools.js");
const {
  createSchool,
  getAllSchools,
  getDriverSchools,
  addSchoolToDriver,
  removeSchoolFromDriver,
  findSchoolsByIds,
  findSchoolById,
  findSchoolNamesByIds,
  getSchoolStudents,
  getSchoolStudentsByDriver,
  updateOrderByDriver,
  getSchoolStudentsByDriverWithoutDirection,
} = controller;
const {
  getSchoolsSingleDriver,
} = require("../controllers/driver_controllers/drivers.js");

router.post("/createSchool", auth, createSchool);
router.get("/getAllSchools", getAllSchools);
router.post("/getDriverSchools", auth, getDriverSchools);
router.post("/addSchoolToDriver", auth, addSchoolToDriver);
router.post("/removeSchoolFromDriver", auth, removeSchoolFromDriver);
router.post("/findSchoolsByIds", auth, findSchoolsByIds);
router.post("/findSchoolById", auth, findSchoolById);
router.post("/findSchoolNamesByIds", auth, findSchoolNamesByIds);
router.post("/getSchoolStudents", auth, getSchoolStudents);
router.post("/getSchoolStudentsByDriver", auth, getSchoolStudentsByDriver);
router.post("/updateOrderByDriver", auth, updateOrderByDriver);
router.post("/getSchoolStudentsByDriverWithoutDirection", auth, getSchoolStudentsByDriverWithoutDirection);

getSchoolStudentsByDriverWithoutDirection
//router.post('/getDriverSchools', getSchoolsSingleDriver);

module.exports = router;
