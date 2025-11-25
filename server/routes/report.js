const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const controller = require("../controllers/report_controllers/report.js");
const {
  incomeReportBySchool,
  incomeReportByStudent,
  expenseReport,
  generatePDF,
} = controller;

router.post("/incomeReportBySchool", auth, incomeReportBySchool);
router.post("/incomeReportByStudent", auth, incomeReportByStudent);
router.post("/expenseReport", auth, expenseReport);
router.post("/generatePDF", auth, generatePDF);
module.exports = router;
