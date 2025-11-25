const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const maps_controllers = require("../controllers/maps_controllers/maps.js");

router.post("/reverseGeocoding", auth, maps_controllers.reverseGeocoding);
router.post("/geocoding", auth, maps_controllers.geocoding);
router.post("/calculateDistance", auth, maps_controllers.calculateDistance);

module.exports = router;
