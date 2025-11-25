const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const location_controllers = require("../controllers/driver_controllers/location.js");

router.post("/sendLocation", auth, location_controllers.sendLocation);
router.post("/getLocation", auth, location_controllers.getLocation);

module.exports = router;
