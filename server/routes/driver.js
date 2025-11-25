const express = require("express");
const router = express.Router();
const { check } = require("express-validator");
const { auth, isDriver, isParent } = require("../middleware/login.js");

const driver_controllers = require("../controllers/driver_controllers/drivers.js");
const account_controllers = require("../controllers/driver_controllers/account.js");
const payment_controllers = require("../controllers/driver_controllers/payment.js");
const expense_controllers = require("../controllers/driver_controllers/expense.js");
const driverConfig_controllers = require("../controllers/driverConfig_controllers/driverConfig.js");
const note_controllers = require("../controllers/driver_controllers/note.js");
const subscription_controllers = require("../controllers/driver_controllers/subscription.js");
const document_controllers = require("../controllers/document_controller/document.js");

const {
  getAgendaEntries,
} = require("../controllers/agendaEntry_controllers/agendaEntry.js");

router.get("/tryDriver", driver_controllers.tryDriver);

// Driver CRUD
router
  .get("/getAllDrivers", auth, isDriver, driver_controllers.getAllDrivers)
  .post(
    "/getDriverByPhone",
    auth,
    isDriver,
    driver_controllers.getDriverByPhone
  )
  .post(
    "/getSchoolsByDriver",
    auth,
    isDriver,
    driver_controllers.getSchoolsSingleDriver
  )
  .delete(
    "/deleteDriverByPhone",
    auth,
    isDriver,
    driver_controllers.deleteDriverByPhone
  );
// Payments
router
  .post("/viewPayments", auth, isDriver, payment_controllers.viewPayments)
  .post(
    "/viewUnpaidPayments",
    auth,
    isDriver,
    payment_controllers.viewUnpaidPayments
  )
  .post("/updatePayment", auth, isDriver, payment_controllers.updatePayment)
  .post("/postponePayment", auth, isDriver, payment_controllers.postponePayment)
  .post(
    "/calculateIncomeBySchool",
    auth,
    isDriver,
    payment_controllers.calculateIncomeBySchool
  )
  .post("/calculateIncome", auth, isDriver, payment_controllers.calculateIncome)
  .post(
    "/getFinancialAgenda",
    auth,
    isDriver,
    payment_controllers.getFinancialAgenda
  )
  .post("/addAdditionalPayment", auth, payment_controllers.addAdditionalPayment)
  .post("/makeRaise", auth, payment_controllers.makeRaise)
  .post("/getMakeRaiseInfo", auth, payment_controllers.getMakeRaiseInfo);

// Expense
router
  .post("/addExpense", auth, isDriver, expense_controllers.addExpense)
  .post(
    "/viewTodaysExpense",
    auth,
    isDriver,
    expense_controllers.viewTodaysExpense
  )
  .post(
    "/getDriverExpense",
    auth,
    isDriver,
    expense_controllers.getDriverExpense
  );

// Account
router
  .delete("/deleteIBAN", auth, isDriver, account_controllers.deleteIBAN)
  .post("/addAccount", auth, isDriver, account_controllers.addAccount)
  .post("/updateAccount", auth, isDriver, account_controllers.updateAccount)
  .post(
    "/getAccountsByDriver",
    auth,
    isDriver,
    account_controllers.getAccountsByDriver
  );

// Driver config
router
  .post(
    "/updateDueDate",
    auth,
    isDriver,
    driverConfig_controllers.updateDueDate
  )
  .post(
    "/getDriverConfig",
    auth,
    isDriver,
    driverConfig_controllers.getDriverConfig
  )
  .post(
    "/getDriverConfigsByDriver",
    auth,
    isDriver,
    driverConfig_controllers.getDriverConfigsByDriver
  )
  .post(
    "/getDueDatesForSchools",
    auth,
    isDriver,
    driverConfig_controllers.getDueDatesForSchools
  );

// Note
router
  .post("/addNote", auth, note_controllers.addNote)
  .post("/getNotes", auth, note_controllers.getNotes)
  .post(
    "/updateNoteDescription",
    auth,
    note_controllers.updateNoteDescription
  )
  .delete("/deleteNote", auth, note_controllers.deleteNote);

// Get Logs
router.post("/getAgendaEntries", auth, isDriver, getAgendaEntries);

// Documents

router
  .post(
    "/uploadFile",
    auth,
    isDriver,
    document_controllers.setMulter,
    document_controllers.uploadFile
  )
  .post("/getFiles", auth, isDriver, document_controllers.getFiles)
  .post("/retrieveFile", auth, isDriver, document_controllers.retrieveFile)
  .delete("/deleteFile", auth, isDriver, document_controllers.deleteFile);

// Subscription
router
  .post(
    "/calculateSubscriptionCost",
    auth,
    subscription_controllers.calculateSubscriptionCost
  )
  .post("/startSubscription", auth, subscription_controllers.startSubscription)
  .post(
    "/getSubscriptionHistory",
    auth,
    subscription_controllers.getSubscriptionHistoryOfDriver
  )
  .post(
    "/calculateRemainingSubscriptionTime",
    auth,
    subscription_controllers.calculateRemainingSubscriptionTime
  )
  .post(
    "/getSubscriptionDetails",
    auth,
    subscription_controllers.getSubscriptionDetails
  )
  .post(
    "/addAdditionalSchoolsToSubscription",
    auth,
    subscription_controllers.addAdditionalSchool
  );

// School bus
router.post("/updateSchoolBus", auth, driver_controllers.updateSchoolBus);
router.post(
  "/getSchoolBusByDriver",
  auth,
  driver_controllers.getSchoolBusByDriver
);

module.exports = router;
