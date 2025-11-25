const allUsers = require("../../models/user.js");
const SchoolBus = require("../../models/schoolBus.js");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Address = require("../../models/address.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

const { User, Parent, Driver, Admin, SchoolAdministrator, CompanyAdmin } =
  allUsers;

const axios = require("axios");
const { password_generator } = require("../../utilities/password_generator.js");
const { sendNewPassword } = require("../sms_controllers/sms.js");
const Subscription = require("../../models/subscription.js");
const Company = require("../../models/company.js");

module.exports.createUser = async (req, res) => {
  const { password, name, email, phone, role, plate, tcno, city } = req.body;

  try {
    let user = await User.findOne({ phone });

    if (user && user.canHaveRoles.includes(role)) {
      logtail.error("User Already Exists");
      logtail.flush();
      return res.status(400).json({ errors: [{ msg: "User already exists" }] });
    }
    if (!user) {
      const hashedPassword = await bcrypt.hash(password, 12);
      const userInfo = {
        name: name,
        password: hashedPassword,
        role: role,
        email: email,
        phone: phone,
        canHaveRoles: [role],
      };

      user = new User(userInfo);
      await user.save();
      if (role === "PARENT") {
        const parentUser = new Parent({
          phone: phone,
          children: [],
        });
        let addressInfo = {
          address: city,
          addressDirections: "",
        };

        let location = await geocodingFunc(city);

        if (location) {
          let { lat, lng } = location;

          addressInfo.lat = lat;
          addressInfo.lon = lng;
          addressInfo.link =
            "https://www.google.com/maps/search/?api=1&query=" +
            lat +
            "," +
            lng;
        }

        let addressObj = new Address(addressInfo);

        await addressObj.save();
        parentUser.address = addressObj._id;
        parentUser._id = user._id;
        await parentUser.save();
      } else if (role === "SCHOOL_ADMINISTRATOR") {
        const schoolAdmin = new SchoolAdministrator({
          phone: phone,
          title: req.body.title,
          school: req.body.school,
        });
        schoolAdmin._id = user._id;
        await schoolAdmin.save();
      } else if (role === "COMPANY_ADMIN") {
        let companyToken;
        if (req.body.companyToken) {
          let company = await Company.findOne({
            companyToken: req.body.companyToken,
          });

          if (!company) {
            logtail.error("No Componay Found with the relevant token!");
            logtail.flush();
            return res.status(400).json({ msg: "No company with that token." });
          }
          companyToken = req.body.companyToken;
        } else {
          let company = new Company({
            companyName: req.body.companyName,
            city: req.body.companyCity,
            whoAddedCompanyPhone: phone,
          });

          await company.save();

          companyToken = company.companyToken;
        }

        const companyAdmin = new CompanyAdmin({
          phone: phone,
          title: req.body.title,
          companyToken: companyToken,
        });
        companyAdmin._id = user._id;
        await companyAdmin.save();
      } else if (role === "DRIVER") {
        const bus = new SchoolBus({
          plate: plate,
          seatCount: 0,
          secondaryUsers: [],
          students: [],
          companyToken: "FREE",
        });
        await bus.save();
        const driverUser = new Driver({
          phone: phone,
          bus: bus._id,
          schools: [],
          documents: [],
          city: city,
          tcno: tcno,
        });
        driverUser._id = user._id;
        await driverUser.save();

        let now = new Date();
        let days15Added = new Date(Date.now() + 15000 * 86400);
        const subscription = new Subscription({
          driver: driverUser._id,
          starts: now,
          ends: days15Added,
          maxSchoolNumber: 3,
          subscriptionType: "TRIAL",
          subscriptionFee: 0,
          lengthInMonths: 0,
        });

        await subscription.save();
      }
      logtail.info("User Created", {
        name: user.name,
        password: password, // Burayı değiştirelim
        role: user.role,
        phone: user.phone,
      });
      logtail.flush();
      return res.status(201).json(user);
    } else {
      if (role === "PARENT") {
        const parentUser = new Parent({
          phone: phone,
          children: [],
        });
        let addressInfo = {
          address: city,
          addressDirections: "",
        };

        let location = await geocodingFunc(city);

        if (location) {
          let { lat, lng } = location;

          addressInfo.lat = lat;
          addressInfo.lon = lng;
          addressInfo.link =
            "https://www.google.com/maps/search/?api=1&query=" +
            lat +
            "," +
            lng;
        }

        let addressObj = new Address(addressInfo);

        await addressObj.save();
        parentUser.address = addressObj._id;
        parentUser._id = user._id;
        await parentUser.save();
      } else if (role === "SCHOOL_ADMINISTRATOR") {
        const schoolAdmin = new SchoolAdministrator({
          phone: phone,
          title: req.body.title,
          school: req.body.school,
        });
        schoolAdmin._id = user._id;
        await schoolAdmin.save();
      } else if (role === "COMPANY_ADMIN") {
        let companyToken;
        if (req.body.companyToken) {
          let company = await Company.findOne({
            companyToken: req.body.companyToken,
          });

          if (!company) {
            return res.status(400).json({ msg: "No company with that token." });
          }
          companyToken = req.body.companyToken;
        } else {
          let company = new Company({
            companyName: req.body.companyName,
            city: req.body.companyCity,
            whoAddedCompanyPhone: phone,
          });

          await company.save();

          companyToken = company.companyToken;
        }

        const companyAdmin = new CompanyAdmin({
          phone: phone,
          title: req.body.title,
          companyToken: companyToken,
        });
        companyAdmin._id = user._id;
        await companyAdmin.save();
      } else if (role === "DRIVER") {
        const bus = new SchoolBus({
          plate: plate,
          seatCount: 0,
          secondaryUsers: [],
          students: [],
          companyToken: "FREE",
        });
        await bus.save();
        const driverUser = new Driver({
          phone: phone,
          bus: bus._id,
          schools: [],
          documents: [],
          city: city,
          tcno: tcno,
        });
        driverUser._id = user._id;
        await driverUser.save();

        let now = new Date();
        let days15Added = new Date(Date.now() + 15000 * 86400);
        const subscription = new Subscription({
          driver: driverUser._id,
          starts: now,
          ends: days15Added,
          maxSchoolNumber: 3,
          subscriptionType: "TRIAL",
          subscriptionFee: 0,
          lengthInMonths: 0,
        });

        await subscription.save();
      }
      const hashedPassword = await bcrypt.hash(password, 12);
      user.password = hashedPassword;
      user.role = role;
      user.canHaveRoles.push(role);
      await user.save();
      logtail.info("User Created", {
        name: user.name,
        password: password, // Burayı değiştirelim
        role: user.role,
        phone: user.phone,
      });
      logtail.flush();
      return res.status(201).json(user);
    }
  } catch (error) {
    logtail.error("Server Error: " + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getLoggedInUser = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];
    const user = await User.findById(req.user.id);
    return res.status(200).json({ result: user, token });
  } catch (e) {
    logtail.error(e.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};

module.exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find({});
    return res.status(200).json(users);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error: " + error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.switchUserType = async (req, res) => {
  try {
    let { phone, role } = req.body;
    const user = await User.findOne({ phone: phone });

    if (!user) {
      logtail.error("User not found");
      return res.status(404).json({ msg: "Error: User not found" });
    }
    if (!user.canHaveRoles.includes(role)) {
      logtail.error("Given role is not included in the possible roles of user");
      return res.status(400).json({
        msg: "Given role is not included in the possible roles of user",
      });
    }

    user.role = role;
    await user.save();

    const userForToken = {
      id: user.id,
      role: user.role,
      phone: user.phone,
    };
    const token = jwt.sign(userForToken, process.env.JWTSECRET);

    return res.status(200).json({ user: user, token: token });
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
module.exports.getUserById = async (req, res) => {
  try {
    let user = await User.findById(req.params.id);
    if (!user) {
      logtail.error("Error: User not found");
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(200).json(user);
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.deleteUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    await user.remove();
    return res.status(200).json({ msg: "User removed successfully" });
  } catch (error) {
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    logtail.error(error.message);
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getParentByPhone = async (req, res) => {
  const { phone } = req.body;
  try {
    let user = await allUsers.User.findOne({ phone: phone });

    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    const parInfo = {
      name: user.name,
      phone: user.phone,
    };

    let parent = await allUsers.Parent.findOne({ phone: phone });
    if (!parent) {
      return res.status(200).json(parInfo);
    } else {
      var addRess = await Address.findById(parent.address.toString());
      parInfo.address = addRess.address;
      parInfo.addressDirections = addRess.addressDirections;
      if (!addRess) {
        return res.status(404).json({ msg: "Error: Adress not found" });
      }
      return res.status(200).json(parInfo);
    }
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDriverByPhone = async (req, res) => {
  const { phone } = req.body;
  try {
    let user = await allUsers.User.findOne({ phone: phone, role: "DRIVER" });
    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(200).json(user);
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getAdminByPhone = async (req, res) => {
  const { phone } = req.body;
  try {
    let user = await allUsers.User.findOne({ phone: phone, role: "PARENT" });
    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(200).json(user);
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getSchoolAdminByPhone = async (req, res) => {
  const { phone } = req.body;
  try {
    let user = await allUsers.User.findOne({
      phone: phone,
      role: "SCHOOL_ADMINISTRATOR",
    });
    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(200).json(user);
  } catch (error) {
    logtail.error(error.message);
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword, newPasswordAgain, phone } = req.body;
    let user = await allUsers.User.findOne({ phone: phone });

    if (!user) {
      return res.status(404).send({ msg: "No user with given phone." });
    }
    const passwordMatches = await bcrypt.compare(
      currentPassword,
      user.password
    );

    if (!passwordMatches) {
      return res.status(400).send({ msg: "Given password does not match" });
    }

    if (newPassword != newPasswordAgain) {
      return res
        .status(404)
        .send({ msg: "New password is not matched with new password again" });
    }
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    user.password = hashedPassword;
    await user.save();
    return res.status(200).send(user);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.forgetPassword = async (req, res) => {
  try {
    const { phone, forgetPasswordCode } = req.body;

    let user = await allUsers.User.findOne({ phone: phone });

    if (!user) {
      return res.status(404).send({ msg: "No user with given phone." });
    }

    if (user.isForgetPasswordCodeUsed == true) {
      return res
        .status(400)
        .send({ msg: "This verification code is already used." });
    }

    if (user.forgetPasswordCode != forgetPasswordCode) {
      return res.status(400).send({ msg: "Verification code does not match!" });
    }

    user.isForgetPasswordCodeUsed = true;
    let randomPassword = password_generator();
    let hashedRandomPassword = await bcrypt.hash(randomPassword, 12);
    user.password = hashedRandomPassword;
    await user.save();

    let check = sendNewPassword(phone, randomPassword);
    if (check)
      return res.status(200).send({
        msg: "New password sent to the given phone if there exists an account exists with that phone.",
      });
    else {
      return res.status(400).send({
        msg: "A problem occurred while SMS is being sent.",
      });
    }
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.sendForgetPasswordCode = async (req, res) => {
  try {
    const { phone } = req.body;

    let user = await allUsers.User.findOne({ phone: phone });

    if (!user) {
      return res.status(200).send({
        msg: "Code is sent successfully if a user with that phone exists.",
      });
    }
    let code = Math.floor(1000 + Math.random() * 9000);
    user.forgetPasswordCode = code;
    user.isForgetPasswordCodeUsed = false;
    await user.save();

    let smsAddress = "https://api.netgsm.com.tr/sms/send/otp";

    xmlBodyStr =
      "<?xml version='1.0'?><mainbody><header><usercode>" +
      process.env.NETGSM_USERNAME +
      "</usercode><password>" +
      process.env.NETGSM_PASSWORD +
      "</password><msgheader>" +
      process.env.NETGSM_MSGHEADER +
      "</msgheader></header><body><msg><![CDATA[" +
      "Şifre değiştirmek için onay kodunuz: " +
      code +
      "." +
      "]]></msg><no>" +
      phone +
      "</no></body></mainbody>";
    let config = {
      headers: { "Content-Type": "application/xml" },
    };
    axios
      .post(smsAddress, xmlBodyStr, config)
      .then(function (response) {
        return res.status(200).send({
          msg: "Code is sent successfully if a user with that phone exists.",
        });
      })
      .catch(function (error) {
        return res.status(500).send({ msg: "Server Error: " + error.message });
      });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.isSchoolAdminApproved = async (req, res) => {
  try {
    const { phone } = req.body;
    let schoolAdmin = await SchoolAdministrator.findOne({ phone: phone });

    return res.status(200).send({ isApproved: schoolAdmin.isApproved });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.isCompanyAdminApproved = async (req, res) => {
  try {
    const { phone } = req.body;
    let companyAdmin = await CompanyAdmin.findOne({ phone: phone });

    return res.status(200).send({ isApproved: companyAdmin.isApproved });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
