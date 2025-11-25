const express = require("express");
const router = express.Router();
const { auth, isDriver } = require("../middleware/login.js");
const sms_controllers = require("../controllers/sms_controllers/sms.js");

router
  .post("/shareIBAN", auth, isDriver, sms_controllers.shareIBAN)
  .post(
    "/gettingCloseSendSMS",
    auth,
    isDriver,
    sms_controllers.gettingCloseSendSMS
  )
  .post("/askForPayment", auth, isDriver, sms_controllers.askForPayment)
  .post("/callParent", sms_controllers.callParent);

module.exports = router;
