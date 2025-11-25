const express = require("express");
const router = express.Router();
const { check } = require("express-validator");
const { auth, isParent, isDriver } = require("../middleware/login.js");
const {
  createUser,
  getParentByPhone,
  getDriverByPhone,
  forgetPassword,
  sendForgetPasswordCode,
  updatePassword,
  switchUserType,
  getLoggedInUser,
  isCompanyAdminApproved,
  isSchoolAdminApproved,
} = require("../controllers/user_controllers/users.js");

router
  .post("/signup", createUser)
  .post("/getParentByPhone", auth, isDriver, getParentByPhone)
  .post("/getDriverByPhone", auth, isDriver, getDriverByPhone)
  .post("/updatePassword", auth, updatePassword)
  .post("/sendForgetPasswordCode", sendForgetPasswordCode)
  .post("/forgetPassword", forgetPassword)
  .post("/switchUserType", switchUserType)
  .post("/isSchoolAdminApproved", isSchoolAdminApproved)
  .post("/isCompanyAdminApproved", isCompanyAdminApproved);

router.get("/getUserByToken", auth, getLoggedInUser);
module.exports = router;
