const express = require("express");
const router = express.Router();

const { check } = require("express-validator");
const controller = require("../controllers/authentication_controllers/login.js");
const login = controller.loginUser;
const createUser = controller.createUser;

router.post('/', login);

module.exports = router;
