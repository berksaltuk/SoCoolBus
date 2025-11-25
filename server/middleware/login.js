const jwt = require("jsonwebtoken");

module.exports.auth = function (req, res, next) {
  const authHeader = req.headers["authorization"];

  const token = authHeader && authHeader.split(" ")[1];
  if (!token) {
    return res.status(401).json({
      msg: "No token found",
    });
  }

  jwt.verify(token, process.env.JWTSECRET, (err, user) => {
    if (err) return res.status(403).json({ msg: "Token is not valid!" });

    req.user = user;
    next();
  });
};

module.exports.isDriver = function (req, res, next) {
  if (req.user.role != "DRIVER")
    return res.status(401).json({
      msg: "You are not a driver.",
    });

  next();
};

module.exports.isParent = function (req, res, next) {
  if (req.user.role != "PARENT")
    return res.status(401).json({
      msg: "You are not a parent.",
    });

  next();
};
