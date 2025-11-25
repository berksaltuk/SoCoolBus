const express = require("express");
const router = express.Router();
const { auth, isDriver, isParent } = require("../middleware/login.js");
const { check } = require("express-validator");
const controller = require("../controllers/idari_controllers/schoolAdministrator.js");
const {
  viewDriversBySchool,
  getStudentMovements,
  getStudentMovementDetails,
  getSchoolBusesList,
} = controller;

router.post("/viewDriversBySchool", auth, viewDriversBySchool);
router.post("/getStudentMovements", auth, getStudentMovements);
router.post("/getStudentMovementDetails", auth, getStudentMovementDetails);
router.post("/getSchoolBusesList", auth, getSchoolBusesList);

module.exports = router;
