const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { validationResult } = require("express-validator");
const School = require("../../models/school.js");
const { Parent } = require("../../models/user.js");
const Student = require("../../models/student.js");
const { Driver } = (allUsers = require("../../models/user.js"));
const Address = require("../../models/address.js");
const DriverConfig = require("../../models/driverConfig.js");
const Subscription = require("../../models/subscription.js");
const ShiftSchedule = require("../../models/shiftSchedule.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.createSchool = async (req, res) => {
  const {
    name,
    address,
    schoolType,
    shiftCount,
    serviceDays,
    firstDevreEnterence,
    firstDevreExit,
    secondDevreEnterance,
    secondDevreExit,
    phone,
  } = req.body;

  try {
    // This part should be already checked by admin

    let school = await School.findOne(
      { name, address } // once the address data type is changed, we might want to check here
    );

    if (school) {
      return res
        .status(400)
        .json({ errors: [{ msg: "School already exists" }] });
    }

    const scoInfo = {
      name,
      address,
      schoolType,
      shiftCount,
      serviceDays, // Ex: ["Pazartesi", "Salı"]
      firstEntranceTime: firstDevreEnterence,
      firstExitTime: firstDevreExit,
      secondEntranceTime: secondDevreEnterance,
      secondExitTime: secondDevreExit,
      whoAddedSchoolPhone: phone,
    };

    /**
     *  ***** *   * * ***** *****   ***** *   * *****  *****
     *  *     *   * * *       *       *    * *  *    * *
     *  ***** ***** * ***     *       *     *   *****  ***       // hatıra diye silmedik, res: adamsınız...
     *      * *   * * *       *       *     *   *      *
     *  ***** *   * * *       *       *     *   *      *****
     */

    school = new School(scoInfo);
    await school.save();

    return res.status(200).json(school);
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send("Server Error: " + error);
  }
};

module.exports.getAllSchools = async (req, res) => {
  try {
    const schools = await School.find();
    return res.status(200).json(schools);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDriverSchools = async (req, res) => {
  const { phone } = req.body;

  try {
    const school_ids = await Driver.find({ phone }, { schools: 1, _id: 0 });
    if (!school_ids || !school_ids.at(0) || !school_ids.at(0).schools) {
      console.log("No school found for this driver");
      return res.status(404).send("Not found: No school found for this driver");
    } else {
      const schools = await School.find({
        _id: { $in: school_ids.at(0).schools },
      });
      return res.status(200).json(schools);
    }
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.addSchoolToDriver = async (req, res) => {
  try {
    const { phone, school_id } = req.body;

    const driver = await Driver.findOne({ phone: phone });

    if (!driver) {
      return res.status(404).json({ msg: "No driver with this phone." });
    }

    const school = await School.findById(school_id);
    if (!school) {
      return res.status(404).json({ msg: "No school with this id." });
    }

    if (driver.schools.includes(school_id))
      return res
        .status(418)
        .json(
          "Well, this driver already added this school, and... I am a teapot!"
        );

    let subscription = await Subscription.findOne({ driver: driver._id });

    if (driver.schools.length + 1 > subscription.maxSchoolNumber) {
      return res
        .status(418)
        .json(
          "Well, your subscription only allows " +
            subscription.maxSchoolNumber +
            ", and... I am a teapot!"
        );
    }

    driver.schools.push(school_id);
    await driver.save();

    var now = new Date();

    const driverConfigInfo = {
      driverPhone: phone,
      school: school_id,
      dueDate: now.getDate(),
    };

    let driverConfig = new DriverConfig(driverConfigInfo);
    await driverConfig.save();

    let shiftSchedule = new ShiftSchedule({
      driver: driver._id,
      school: school._id,
    });

    await shiftSchedule.save();

    return res
      .status(200)
      .json({ schools: driver.schools, driverConfigForSchool: driverConfig });
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

module.exports.removeSchoolFromDriver = async (req, res) => {
  try {
    const { phone, school_id } = req.body;

    const driver = await Driver.findOne({ phone: phone });

    if (!driver) {
      return res.status(404).json({ msg: "No driver with this phone." });
    }

    if (!driver.schools.includes(school_id))
      return res.status(418).json({
        msg: "Well, this driver does not have this school, and... I am a teapot!",
      });

    driver.schools = driver.schools.filter((val) => val != school_id);
    await driver.save();

    await DriverConfig.findOneAndDelete({
      school: school_id,
      driverPhone: phone,
    });

    return res.status(200).json(driver.schools);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};
module.exports.findSchoolsByIds = async (req, res) => {
  try {
    const ids = req.body.ids;
    const schools = await School.find({ _id: { $in: ids } });
    return res.status(200).json(schools);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

module.exports.findSchoolById = async (req, res) => {
  try {
    const id = req.body.id;
    const school = await School.findById(id);
    return res.status(200).json(school);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

module.exports.findSchoolNamesByIds = async (req, res) => {
  try {
    const ids = req.body.ids;
    const schools = await School.find({ _id: { $in: ids } });
    return res.status(200).json(
      schools.map((school) => {
        return {
          _id: school._id,
          name: school.name,
        };
      })
    );
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

//TO DO: Need to implement address directions
module.exports.getSchoolStudents = async (req, res) => {
  const { schoolId } = req.body;

  try {
    const students = await Student.find(
      { school: schoolId },
      { name: 1, secondPhoneNumber: 1, _id: 1, parent: 1 }
    );
    for (i in students) {
      const parent = await Parent.findById(students[i].parent.toString());
      const address = await Address.find(
        { _id: parent.address.toString() },
        { address: 1, link: 1, _id: 0 }
      );

      students[i] = Object.assign({}, students[i]._doc, address[0]._doc);
      students[i] = Object.assign({}, students[i], {
        addressDirections: "Not yet implemented",
      });
    }
    return res.status(200).json(students);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

/**
 * Finds students that in the given
 * school and in the school bus of
 * the given driver
 * !!  schoolStartTime: sabahçı:0 öğleci:1 tam gün:2
 * !!  direction: okula giriş: 0, okuldan çıkış: 1
 * orderH2S: öğrencinin evden okula giderkenki servise biniş sırası
 * orderS2H: öğrencinin okuldan eve giderkenki iniş sırası
 * @param {*} req
 * @param {*} res
 */
module.exports.getSchoolStudentsByDriver = async (req, res) => {
  try {
    const { schoolID, driverPhone, direction } = req.body;
    let driver = await Driver.findOne({ phone: driverPhone }).populate("bus");

    let school = await School.findById(schoolID);

    let schoolStartTime;

    if (school.shiftCount == 2) {
      let sst = req.body.schoolStartTime;
      if (sst != 0 && sst != 1) {
        return res
          .status(400)
          .send({ msg: "given school start time number is not valid!" });
      }
      schoolStartTime = sst;
    } else {
      schoolStartTime = 2;
    }

    if (direction != 0 && direction != 1) {
      return res
        .status(400)
        .send({ msg: "given direction number is not valid!" });
    }
    let directionPreference =
      direction === 0
        ? {
            $in: [1, 2],
          }
        : {
            $in: [1, 3],
          };

    let students = await Student.find({
      _id: { $in: driver.bus.students },
      school: schoolID,
      schoolStartTime: schoolStartTime,
      directionPreference: directionPreference,
    }).populate({
      path: "parent",
      populate: {
        path: "address",
      },
    });

    let students_sorted;
    if (direction == 0) {
      students_sorted = students.sort(
        (firstItem, secondItem) =>
          firstItem.orderByDriverH2S - secondItem.orderByDriverH2S
      );
    } else {
      students_sorted = students.sort(
        (firstItem, secondItem) =>
          firstItem.orderByDriverS2H - secondItem.orderByDriverS2H
      );
    }

    let students_mapped = students_sorted.map((student) => {
      return {
        _id: student._id,
        name: student.name,
        secondPhoneNumber: student.secondPhoneNumber
          ? student.secondPhoneNumber
          : student.parent.phone,
        //parent: student.parent._id,
        address: student.parent.address.address,
        addressDirections: student.parent.address.addressDirections,
        link: student.parent.address.link,
        orderH2S: student.orderByDriverH2S,
        orderS2H: student.orderByDriverS2H,
      };
    });

    return res.status(200).json(students_mapped);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getSchoolStudentsByDriverWithoutDirection = async (req, res) => {
  try {
    const { schoolID, driverPhone } = req.body;
    let driver = await Driver.findOne({ phone: driverPhone }).populate("bus");

    let students = await Student.find({
      _id: { $in: driver.bus.students },
      school: schoolID,
    }).populate({
      path: "parent",
      populate: {
        path: "address",
      },
    });

    let students_mapped = students.map((student) => {
      return {
        _id: student._id,
        name: student.name,
        secondPhoneNumber: student.secondPhoneNumber,
        //parent: student.parent._id,
        address: student.parent.address.address,
        addressDirections: student.parent.address.addressDirections,
        link: student.parent.address.link,
      };
    });

    return res.status(200).json(students_mapped);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

/**
 * Send the list of IDs of students that you want to reorder
 * if there is 25 students and the last student you reordered was
 * 5, then send the IDs of first 5 students.
 * H2S or S2H order can be updated so in the req body direction must be given
 * @param {*} req
 * @param {*} res
 */
module.exports.updateOrderByDriver = async (req, res) => {
  try {
    let { studentIDs, direction } = req.body;

    studentIDs = studentIDs.substring(1, studentIDs.length - 1);
    let arr = studentIDs.split(", ");

    let unorderedStudents = await Student.find({
      _id: { $in: arr },
    });
    let obj = {};

    unorderedStudents.forEach((x) => (obj[x._id] = x));
    let students = arr.map((key) => obj[key]);

    console.log(students.map((student) => student._id));
    let students_mapped;

    if (direction == 0) {
      for (let i = 0; i < students.length; i++) {
        students[i].orderByDriverH2S = i + 1;
      }

      students_mapped = students.map((student) => {
        return {
          updateOne: {
            filter: { _id: student._id },
            update: {
              $set: {
                orderByDriverH2S: student.orderByDriverH2S,
              },
            },
          },
        };
      });
    } else {
      for (let i = 0; i < students.length; i++) {
        students[i].orderByDriverS2H = i + 1;
      }

      students_mapped = students.map((student) => {
        return {
          updateOne: {
            filter: { _id: student._id },
            update: {
              $set: {
                orderByDriverS2H: student.orderByDriverS2H,
              },
            },
          },
        };
      });
    }
    await Student.bulkWrite(students_mapped);

    return res
      .status(200)
      .json({ msg: "Student ordering by driver is updated successfully." });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
