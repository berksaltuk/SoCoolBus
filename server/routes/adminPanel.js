const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const controller = require("../controllers/adminPanel_controllers/adminPanel.js");
const {
  approveOrRejectCompany,
  approveOrRejectCompanyAdmin,
  approveOrRejectDocument,
  approveOrRejectSchool,
  approveOrRejectSchoolAdmin,
  addAdmin,
  adminLogin,
  getUnapprovedSchools,
  getUnapprovedDocuments,
  getUnapprovedSchoolAdmins,
  getUnapprovedCompanies,
  getUnapprovedCompanyAdmins,
  getAdminList,
} = controller;

router
  .post("/approveOrRejectCompany", approveOrRejectCompany)
  .post("/approveOrRejectCompanyAdmin", approveOrRejectCompanyAdmin)
  .post("/approveOrRejectDocument", approveOrRejectDocument)
  .post("/approveOrRejectSchool", approveOrRejectSchool)
  .post("/approveOrRejectSchoolAdmin", approveOrRejectSchoolAdmin)
  .post("/addAdmin", addAdmin)
  .post("/adminLogin", adminLogin)
  .get("/getUnapprovedSchools", getUnapprovedSchools)
  .get("/getUnapprovedDocuments", getUnapprovedDocuments)
  .get("/getUnapprovedSchoolAdmins", getUnapprovedSchoolAdmins)
  .get("/getUnapprovedCompanies", getUnapprovedCompanies)
  .get("/getUnapprovedCompanyAdmins", getUnapprovedCompanyAdmins)
  .get("/getAdminList", getAdminList);

module.exports = router;
