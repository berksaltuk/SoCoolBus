const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const controller = require("../controllers/idari_controllers/companyAdmin.js");
const {
  viewDriversByCompany,
  getStudentMovementsByCompanyAdmin,
  getSchoolBusesList,
  addDriverToSchoolBusByCompanyAdmin,
  addSchoolBusByCompanyAdmin,
} = controller;

const schoolAdmin_controllers = require("../controllers/idari_controllers/schoolAdministrator.js");
/**
 *
  getStudentMovementDetails,
  getSchoolBusesList,
 */
router.post("/viewDriversByCompany", auth, viewDriversByCompany);
router.post(

"/addDriverToSchoolBusByCompanyAdmin", addDriverToSchoolBusByCompanyAdmin
);
router.post("/addSchoolBusByCompanyAdmin", addSchoolBusByCompanyAdmin);

router.post(
  "/getStudentMovementsByCompanyAdmin",
  auth,
  getStudentMovementsByCompanyAdmin
);
router.post(
  "/getStudentMovementDetails",
  auth,
  schoolAdmin_controllers.getStudentMovementDetails
);

router.post("/getSchoolBusesList", getSchoolBusesList);
module.exports = router;
