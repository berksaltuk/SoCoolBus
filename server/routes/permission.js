const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/login.js");
const controller = require("../controllers/permission_controllers/permission.js");
const {
  givePermission,
  updatePermission,
  deletePermission,
  viewStudentsPermissions,
  getPermission,
} = controller;

router.post("/givePermission", auth, givePermission);
router.post("/updatePermission", auth, updatePermission);
router.post("/deletePermission", auth, deletePermission);
router.post("/getPermission", auth, getPermission);
router.post("/viewStudentsPermissions", auth, viewStudentsPermissions);
module.exports = router;
