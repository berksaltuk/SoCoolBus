const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const allUsers = require("../../models/user.js");
const User = allUsers.User;
const { validationResult } = require("express-validator");
const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.loginUser = async (req, res) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    logtail.error(errors.array());
    logtail.flush();
    return res.status(400).json({ errors: errors.array() });
  }

  const { phone, password } = req.body;

  try {
    let userObj = await User.findOne({ phone });
    if (!userObj) {
      logtail.error("User does not exist!");
      logtail.flush();
      return res.status(400).json({ errors: [{ msg: "User does not exist" }] });
    }

    const passwordMatches = await bcrypt.compare(password, userObj.password);

    if (!passwordMatches) {
      return res.status(400).json({ errors: [{ msg: "Invalid Credentials" }] });
    }

    const user = {
      id: userObj.id,
      role: userObj.role,
      phone: userObj.phone,
    };
    const token = jwt.sign(user, process.env.JWTSECRET);

    return res.status(200).json({ result: userObj, token });
  } catch (e) {
    logtail.error("Something went wrong" + e.message);
    logtail.flush();
    return res
      .status(500)
      .json({ message: "Something went wrong. Error: " + e.message });
  }
};
