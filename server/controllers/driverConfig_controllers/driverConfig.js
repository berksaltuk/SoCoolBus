const DriverConfig = require("../../models/driverConfig");
const School = require("../../models/school");
const Payment = require("../../models/payment");
const Student = require("../../models/student");
const { Driver } = require("../../models/user");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

//due date format should be considered again
module.exports.updateDueDate = async (req, res) => {
  try {
    const driverConfig = await DriverConfig.findById(req.body.id);
    givenDueDate = req.body.dueDate;

    if (givenDueDate > 0 && givenDueDate < 32)
      driverConfig.dueDate = givenDueDate;
    else return res.status(400).send({ msg: "Due date must be in [1,31]" });

    let driverPhone = driverConfig.driverPhone;
    let school = driverConfig.school;

    let driver = await Driver.findOne({ phone: driverPhone }).populate("bus");
    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }
    let busStudents = driver.bus.students;

    let query_find_student = {
      school: school,
      _id: { $in: busStudents },
    };
    const students = await Student.find(query_find_student);
    if (!students) {
      return res.status(404).send({
        success: false,
        errorMsg: "No students returned.",
      });
    }

    let students_ids = students.map((student) => {
      return student._id.toHexString();
    });

    let query = {
      paidTo: driverPhone,
      paidBy: { $in: students_ids },
      paymentStatus: "unpaid",
    };

    let payments = await Payment.find(query);

    payments_mapped = payments.map((payment) => {
      return {
        updateOne: {
          filter: { _id: payment._id },
          update: {
            $set: {
              dueDate: payment.dueDate?.setDate(givenDueDate),
              lastUpdate: new Date(),
            },
          },
        },
      };
    });

    await Payment.bulkWrite(payments_mapped);

    await driverConfig.save();
    return res.status(200).send(driverConfig);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.addDueDate = async (req, res) => {
  try {
    if (!(await School.findById(req.body.schoolID))) {
      return res.status(404).send({
        success: false,
        errorMsg: "No schools found by given school id.",
      });
    }
    if (!(await Driver.findOne({ phone: req.body.driverPhone }))) {
      return res.status(404).send({
        success: false,
        errorMsg: "No driver found by given driver phone.",
      });
    }

    let schoolID = req.body.schoolID;
    let driverPhone = req.body.driverPhone;
    let dueDate = req.body.dueDate;

    const driverConfig = new DriverConfig({
      school: schoolID,
      driverPhone: driverPhone,
      dueDate: dueDate,
    });

    await driverConfig.save();
    return res.status(200).send(driverConfig);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDriverConfig = async (req, res) => {
  try {
    const driverConfig = await DriverConfig.find({
      driverPhone: req.body.driverPhone,
      school: req.body.schoolID,
    });

    if (!driverConfig) {
      return res.status(404).send({
        success: false,
        errorMsg: "No driverConfig for driver and school ID pair.",
      });
    }
    return res.status(200).send(driverConfig);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDriverConfigsByDriver = async (req, res) => {
  try {
    const driverConfig = await DriverConfig.find({
      driverPhone: req.body.driverPhone,
    }).populate("school");

    if (!driverConfig) {
      return res.status(404).send({
        success: false,
        errorMsg: "No driverConfig for driver.",
      });
    }
    return res.status(200).send(driverConfig);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDueDatesForSchools = async (req, res) => {
  try {
    const driverConfig = await DriverConfig.find({
      driverPhone: req.body.driverPhone,
    }).populate("school");

    if (!driverConfig) {
      return res.status(404).send({
        success: false,
        errorMsg: "No driverConfig for driver.",
      });
    }
    return res.status(200).send(
      driverConfig.map((config) => {
        return {
          id: config._id,
          dueDate: config.dueDate,
          schoolName: config.school.name,
        };
      })
    );
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
