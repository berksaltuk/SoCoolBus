const { SchoolAdministrator, User, Driver } = require("../../models/user");
const Student = require("../../models/student");
const ParentDailyFlowEntry = require("../../models/parentDailyFlowEntry");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.viewDriversBySchool = async (req, res) => {
  try {
    const { school } = req.body;

    const drivers = await Driver.find({ schools: school }).populate("bus");

    const driverPhones = drivers.map((driver) => driver.phone);

    let startOfDay = new Date();
    startOfDay.setUTCHours(0, 0, 0, 0);

    let endOfDay = new Date();
    endOfDay.setUTCHours(23, 59, 59, 999);
    const results = await Driver.aggregate([
      {
        $match: {
          phone: { $in: driverPhones },
        },
      },
      {
        $lookup: {
          from: "shifts",
          localField: "phone",
          foreignField: "driverPhone",
          pipeline: [
            {
              $match: {
                startTime: { $gte: startOfDay, $lte: endOfDay },
              },
            },
            {
              $sort: {
                startTime: -1,
              },
            },
            {
              $limit: 1,
            },
          ],
          as: "shift",
        },
      },
      {
        $lookup: {
          from: "schoolbuses",
          localField: "bus",
          foreignField: "_id",

          as: "schoolbus",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "phone",
          foreignField: "phone",

          as: "user",
        },
      },
      { $unwind: "$user" },
      { $unwind: "$schoolbus" },
      {
        $project: {
          name: "$user.name",
          plate: "$schoolbus.plate",
          startTime: "$shift.startTime",
          endTime: "$shift.endTime",
          lastStudentTakenAt: "$shift.lastStudentTakenAt",
        },
      },
    ]);

    let driverInfo = results.map((res) => {
      return {
        driverName: res.name,
        plate: res.plate,
        startTime: res.startTime[0],
        endTime: res.endTime[0],
        lastStudentTakenAt: res.lastStudentTakenAt[0],
        status:
          res.startTime.length == 0
            ? "Servise Başlamadı"
            : res.endTime.length == 0
            ? res.lastStudentTakenAt.length == 0
              ? "Toplama Bitmedi"
              : "Toplama Bitti"
            : "Giriş Yaptı",
      };
    });

    let result = {
      all: driverInfo.length,
      onShift: driverInfo.filter(
        (info) =>
          info.status == "Toplama Bitmedi" || info.status == "Toplama Bitti"
      ).length,
      inSchool: driverInfo.filter((info) => info.status == "Giriş Yaptı")
        .length,
      notStarted: driverInfo.filter(
        (info) => info.status == "Servise Başlamadı"
      ).length,
      driverInfo,
    };
    return res.status(200).send(result);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getStudentMovements = async (req, res) => {
  try {
    const { phone } = req.body;

    const schoolAdmin = await SchoolAdministrator.findOne({
      phone: phone,
    });

    let school = schoolAdmin.school;

    const students = await Student.find({
      school: school,
      onShift: true,
    })
      .populate({
        path: "parent",
        populate: {
          path: "address",
        },
      })
      .populate({
        path: "currentShift",
        populate: {
          path: "driver",
          populate: {
            path: "bus",
          },
        },
      });

    console.log(students);

    let studentsInfo = await Promise.all(
      students.map(async (element) => {
        let user = await User.findOne({
          phone: element.currentShift.driver.phone,
        });
        return {
          studentID: element._id,
          studentName: element.name,
          plate: element.currentShift.driver.bus.plate,
          parentPhone: element.parent.phone,
          address: element.parent.address.address,
          driverName: user.name,
        };
      })
    );
    return res.status(200).json(studentsInfo);
  } catch (e) {
    console.error(e.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};

module.exports.getStudentMovementDetails = async (req, res) => {
  try {
    const { studentID, fromDate, toDate } = req.body;

    const studentFound = await Student.findById(studentID);

    const results = await ParentDailyFlowEntry.find({
      student: studentID,
      date: { $gte: fromDate, $lte: toDate },
      entryType: "shift",
    });

    const result = {
      studentName: studentFound.name,
      movements: results.map((result) => {
        return {
          movement: result.mainHeader,
          time: result.date.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
        };
      }),
    };

    return res.status(200).json(result);
  } catch (e) {
    console.error(e.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};

//TO BE CONTINUED
module.exports.getSchoolBusesList = async (req, res) => {
  try {
    const { schoolAdminPhone } = req.body;

    const idariFound = await SchoolAdministrator.findOne({
      phone: schoolAdminPhone,
    });
    let school = idariFound.school;
    const drivers = await Driver.aggregate([
      { $match: { schools: school } },
      {
        $lookup: {
          from: "users",
          localField: "phone",
          foreignField: "phone",
          as: "user",
        },
      },
      {
        $lookup: {
          from: "schoolbuses",
          localField: "bus",
          foreignField: "_id",
          as: "schoolbus",
        },
      },
      { $unwind: "$user" },
      { $unwind: "$schoolbus" },
      {
        $project: {
          name: "$user.name",
          plate: "$schoolbus.plate",
          phone: "$user.phone",
        },
      },
    ]);
    return res.status(200).json(drivers);
  } catch (e) {
    console.error(e.message);
    logtail.error(e.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};
