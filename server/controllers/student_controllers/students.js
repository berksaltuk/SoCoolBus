const { Parent, User, Driver } = require("../../models/user.js");
const Student = require("../../models/student.js");
const Payment = require("../../models/payment.js");
const { addPayment } = require("../driver_controllers/payment.js");
const Address = require("../../models/address.js");
const SchoolBus = require("../../models/schoolBus.js");
const DriverConfig = require("../../models/driverConfig.js");
const bcrypt = require("bcryptjs");
const { geocodingFunc } = require("../maps_controllers/maps.js");
const { password_generator } = require("../../utilities/password_generator.js");
const { sendLoginInformation } = require("../sms_controllers/sms.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.createStudent = async (req, res) => {
  const {
    name,
    school,
    parentName,
    parentPhone,
    secondPhone,
    address,
    directionPref,
    paymentPref,
    whogondothepay,
    duration,
    totalFee,
    driverPhone,
    schoolStartTime, // 0, 1, 2 -> see student object
  } = req.body;
  try {
    let student = await Student.findOne(
      { name: name, secondPhoneNumber: secondPhone } // gonna need to be modified
    );
    if (student) {
      return res
        .status(400)
        .json({ errors: [{ msg: "Student already exists" }] });
    }

    const stuInfo = {
      name: name,
      school: school,
      secondPhoneNumber: secondPhone,
      directionPreference: directionPref,
      paymentPreference: paymentPref,
      whogondothePayment: whogondothepay,
      schoolStartTime: schoolStartTime,
      class: req.body.class,
    };

    student = new Student(stuInfo);

    let parent = await Parent.findOne({ phone: parentPhone });
    let existingUser = await User.findOne({ phone: parentPhone });

    let loginInfoSent;
    if (!existingUser && !parent) {
      let pass = password_generator();
      const userInfo = {
        name: parentName,
        phone: parentPhone,
        password: await bcrypt.hash(pass, 12),
        role: "PARENT",
        canHaveRoles: ["PARENT"],
      };
      const parentInfo = {
        phone: parentPhone,
        children: [],
      };

      let user = new User(userInfo);
      parent = new Parent(parentInfo);
      parent._id = user._id;

      let addressInfo = {
        address: address,
        addressDirections: "",
      };

      let location = await geocodingFunc(address);

      if (location) {
        let { lat, lng } = location;

        addressInfo.lat = lat;
        addressInfo.lon = lng;
        addressInfo.link =
          "https://www.google.com/maps/search/?api=1&query=" + lat + "," + lng;
      }

      let addressObj = new Address(addressInfo);

      await addressObj.save();

      parent.address = addressObj._id;

      await user.save();
      await parent.save();

      loginInfoSent = await sendLoginInformation(
        parentPhone,
        pass,
        driverPhone
      );
    } else if (!parent) {
      const parentInfo = {
        phone: parentPhone,
        children: [],
      };

      parent = new Parent(parentInfo);
      parent._id = existingUser._id;

      let addressInfo = {
        address: address,
        addressDirections: "",
      };

      let location = await geocodingFunc(address);

      if (location) {
        let { lat, lng } = location;

        addressInfo.lat = lat;
        addressInfo.lon = lng;
        addressInfo.link =
          "https://www.google.com/maps/search/?api=1&query=" + lat + "," + lng;
      } else {
        addressInfo.lat = 0;
        addressInfo.lon = 0;
        addressInfo.link =
          "https://www.google.com/maps/search/?api=1&query=0,0";
      }

      let addressObj = new Address(addressInfo);

      await addressObj.save();

      parent.address = addressObj._id;
      existingUser.canHaveRoles.push("PARENT");

      await existingUser.save();
      await parent.save();
    }
    parent.children.push(student._id);
    student.parent = parent._id;

    await student.save();
    await parent.save();

    let driver = await Driver.findOne({ phone: driverPhone });
    let bus = await SchoolBus.findById(driver.bus);
    bus.students.push(student._id);
    await bus.save();

    let driverConfig = await DriverConfig.findOne({
      school: school,
      driverPhone: driverPhone,
    });

    const dueDateDay = driverConfig.dueDate;

    let dueDate;
    let d = new Date();

    let remaining_days_next_month = 0;
    //eğer ki servis parasının alındığı günden sonra geldiyse öğrenci
    //önümüzdeki ay para alacağız
    if (dueDateDay <= new Date().getDate()) {
      let monthV1 = d.getMonth();
      d.setDate(dueDateDay);
      let monthV2 = d.getMonth();
      //aynı olmama ihtimali: ayın 30'unda para alıyorum ama şubat ayındayız
      if (monthV1 == monthV2) {
        d.setMonth(d.getMonth() + 1);
        dueDate = d;
      } else {
        dueDate = d;
      }
      remaining_days_next_month = new Date().getDate() - dueDateDay;
    } else {
      d.setDate(dueDateDay);
      dueDate = d;
    }
    let monthly_fee = totalFee / duration;
    let fraction = (monthly_fee / 30) * remaining_days_next_month;

    const added = await addPayment(
      paymentPref == "1",
      duration,
      monthly_fee,
      student._id,
      dueDate,
      driverPhone,
      fraction
    );

    return res.status(201).json({
      student: student,
      paymentCreated: added,
      parent: parent,
      loginInfoSent: loginInfoSent,
    });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send("Server Error: " + error);
  }
};

module.exports.getStudentSettings = async (req, res) => {
  try {
    const student = await Student.findById(req.body.studentID).populate(
      "school"
    );

    if (!student) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "No student with the given ID." });
    }
    let result = {
      schoolName: student.school.name,
      secondPhone: student.secondPhoneNumber,
      class: student.class,
      smsPreference: student.smsPreference,
      notificationPreference: student.notificationPreference,
      callPreference: student.callPreference,
    };
    return res.status(200).send(result);
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updateStudentSettings = async (req, res) => {
  Student.findOneAndUpdate(
    { _id: req.body.studentID },
    {
      $set: {
        school: req.body.schoolID,
        secondPhoneNumber: req.body.secondPhoneNumber,
        name: req.body.studentName,
        directionPreference: req.body.directionPreference,
        whogondothePayment: req.body.whogondothePayment,
        schoolStartTime: req.body.schoolStartTime,
        class: req.body.class,
        active: req.body.active,
      },
    },
    { new: true }
  )
    .then(() => {
      return res
        .status(200)
        .send({ msg: "Student setting is updated successfully." });
    })
    .catch((error) => {
      logtail.error("Server Error:" + error.message);
      logtail.flush();
      console.error(error.message);
      return res.status(500).send({ msg: "Server Error: " + error.message });
    });
};

module.exports.updateStudentByDriver = async (req, res) => {
  let student = await Student.findById(req.body.studentID).populate("parent");

  let addressObj = await Address.findById(student.parent.address);

  let address = req.body.address;

  if (address === "") address = addressObj.address;

  addressObj.address = address;

  let location = await geocodingFunc(address);
  if (location) {
    let { lat, lng } = location;

    addressObj.lat = lat;
    addressObj.lon = lng;
    addressObj.link =
      "https://www.google.com/maps/search/?api=1&query=" + lat + "," + lng;
  }

  await addressObj.save();

  Student.findOneAndUpdate(
    { _id: req.body.studentID },
    {
      $set: {
        school: req.body.school,
        name: req.body.name,
        secondPhoneNumber: req.body.secondPhoneNumber,
        directionPreference: req.body.directionPreference,
        paymentPreference: req.body.paymentPreference,
        whogondothePayment: req.body.whogondothePayment,
        schoolStartTime: req.body.schoolStartTime,
        class: req.body.class,
      },
    },
    { new: true }
  )
    .then(() => {
      return res.status(200).send({ msg: "Student is updated successfully." });
    })
    .catch((error) => {
      logtail.error("Server Error:" + error.message);
      logtail.flush();
      console.error(error.message);
      return res.status(500).send({ msg: "Server Error: " + error.message });
    });
};

module.exports.deleteStudentByDriver = async (req, res) => {
  try {
    const driverPhone = req.user?.phone;

    let driver = await Driver.findOne({ phone: driverPhone });
    if (!driver) {
      return res
        .status(404)
        .send({ msg: "Driver not found using given phone." });
    }

    let bus = await SchoolBus.findById(driver.bus);
    if (!bus) {
      return res
        .status(404)
        .send({ msg: "School bus is not found for the given driver phone" });
    }

    let student = await Student.findById(req.body.studentID);
    if (!student) {
      return res
        .status(404)
        .send({ msg: "Student is not found for the given student id" });
    }

    console.log(bus.students);
    bus.students = bus.students.filter(
      (student) => student != req.body.studentID
    );

    console.log(bus.students);
    student.active = false;

    await bus.save();
    await student.save();

    return res.status(200).send({ msg: "Student deleted succesfully." });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getStudentsByParent = async (req, res) => {
  try {
    const parent = await Parent.findOne({ phone: req.body.phone });

    if (!parent) {
      return res
        .status(404)
        .send({ msg: "Parent not found using given phone." });
    }
    const students = await Student.find({ parent: parent._id });

    return res.status(200).send(
      students.map((student) => {
        return {
          studentID: student._id,
          studentName: student.name,
        };
      })
    );
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getStudentByDriver = async (req, res) => {
  try {
    const driver = await Driver.findOne({ phone: req.body.phone });
    if (!driver) {
      return res
        .status(404)
        .send({ msg: "Driver not found using given phone." });
    }

    let bus = await SchoolBus.findById(driver.bus);

    if (!bus) {
      return res
        .status(404)
        .send({ msg: "School bus is not found for the given driver phone" });
    }

    let student = await Student.findById(req.body.studentID)
      .populate("school")
      .populate("parent");

    let parentUser = await Parent.findById(student.parent.id);

    if (!student) {
      return res
        .status(404)
        .send({ msg: "Student is not found for the given student id" });
    }

    let address = await Address.findById(student.parent.address);

    let payment = await Payment.find({
      paidBy: req.body.studentID,
      paidTo: driver.phone,
      additional: false,
    }).sort({ originalDueDate: "desc" });
    payment = payment.at(0);

    let result = {
      studentID: student._id,
      name: student.name,
      schoolID: student.school._id,
      schoolName: student.school.name,
      secondPhone: student.secondPhoneNumber,
      directionPreference: student.directionPreference,
      paymentPreference: student.paymentPreference,
      whogondothePayment: student.whogondothePayment,
      schoolStartTime: student.schoolStartTime,
      class: student.class,
      active: student.active,
      parentPhone: student.parent.phone,
      parentName: parentUser.name,
      adress: address,
      amount: payment.originalAmount,
      totalAmount: payment.originalAmount * payment.totalInstallment,
      totalInstallment: payment.totalInstallment,
    };

    return res.status(200).send(result);
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
