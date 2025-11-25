const express = require("express");
const router = express.Router();
const { check } = require("express-validator");
const { auth, isParent } = require("../middleware/login.js");
const {
  updateParentAddress,
  getParentByPhone,
  getChildren,
  getChildrenPayments,
  showPaymentInfo,
} = require("../controllers/parent_controllers/parents.js");

const {
  getTopParentDailyFlowEntries,
  getParentFlowEntriesByStudent,
} = require("../controllers/parentDailyFlowEntry_controllers/parentDailyFlowEntry.js");

router.post("/updateAddress", auth, updateParentAddress);

router.post("/getParent", auth, getParentByPhone);
router.post("/getChildren", auth, getChildren);
router.post(
  "/getTopParentDailyFlowEntries",
  auth,
  getTopParentDailyFlowEntries
);
router.post(
  "/getParentFlowEntriesByStudent",
  auth,
  getParentFlowEntriesByStudent
);
router.post("/getChildrenPayments", getChildrenPayments);
router.post("/showPaymentInfo", auth, showPaymentInfo);

module.exports = router;
