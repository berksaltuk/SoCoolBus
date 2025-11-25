const { Parent, User, Driver } = require("../../models/user.js");
const Student = require("../../models/student.js");
const Address = require("../../models/address.js");
const SchoolBus = require("../../models/schoolBus.js");
const School = require("../../models/school.js");
const Shift = require("../../models/shift.js");
const AgendaEntry = require("../../models/agendaEntry");
const ParentDailyFlowEntry = require("../../models/parentDailyFlowEntry.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

const {
  getSingleStudentPaymentStatus,
} = require("../driver_controllers/payment.js");

const ShiftSchedule = require("../../models/shiftSchedule.js");
const {
  viewStudentsPermissionsFunction,
} = require("../permission_controllers/permission.js");
const Location = require("../../models/location.js");

let statusMap = new Map();
statusMap.set("Beklemede", 100);
statusMap.set("Zamanında Alındı", 200);
statusMap.set("Beklendi Alındı", 201);
statusMap.set("İzinli", 300);
statusMap.set("Beklendi Alınmadı", 301);
statusMap.set("Servise Bindi", 400);
statusMap.set("Servise Binmedi", 401);
statusMap.set("Eve Bırakıldı", 500);
statusMap.set("Konuma Bırakıldı", 501);

module.exports.createShift = async (req, res) => {
  const { schoolID, driverPhone } = req.body;

  try {
    let driver = await Driver.findOne({ phone: driverPhone });
    let school = await School.findById(schoolID);
    let bus = await SchoolBus.findById(driver.bus);

    var now = new Date();
    var todayDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    let shiftSchedule = await ShiftSchedule.findOne({
      driver: driver._id,
      school: school._id,
      date: { $gte: todayDate },
    });

    const shiftCountofSchool = school.shiftCount;
    let shiftName = req.body.shiftName;
    let students = [];

    if (
      (shiftName == "Sabah Giriş" && shiftSchedule.morningEntranceStarted) ||
      (shiftName == "Öğlen Giriş" && shiftSchedule.noonEntranceStarted) ||
      (shiftName == "Öğlen Çıkış" && shiftSchedule.noonExitStarted) ||
      (shiftName == "Akşam Çıkış" && shiftSchedule.eveningExitStarted)
    ) {
      let shift = await Shift.findOne({
        shiftName: shiftName,
        startTime: { $gte: todayDate },
        driverPhone: driverPhone,
        school: school._id,
      });

      return this.getShiftFunction(shift.id, res);
    }

    // New manual shift selection
    if (shiftName == "Sabah Giriş") {
      if (shiftCountofSchool == 1) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 2,
        });
      } else if (shiftCountofSchool == 2) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 0,
        });
      }
    } else if (shiftName == "Öğlen Giriş") {
      students = await Student.find({
        _id: { $in: bus.students },
        school: school._id,
        schoolStartTime: 1,
      });
    } else if (shiftName == "Öğlen Çıkış") {
      students = await Student.find({
        _id: { $in: bus.students },
        school: school._id,
        schoolStartTime: 0,
      });
    } else if ((shiftName = "Akşam Çıkış")) {
      if (shiftCountofSchool == 1) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 2,
        });
      } else if (shiftCountofSchool == 2) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 1,
        });
      }
    } else {
      return res.status(400).json({ msg: "This is not a valid shift name!" });
    }

    // Old automatic shift system
    /*
    if (!shiftSchedule.morningEntranceCompletion) {
      shiftName = "Sabah Giriş";
      if (shiftCountofSchool == 1) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 2,
        });
      } else if (shiftCountofSchool == 2) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 0,
        });
      }
    } else if (
      shiftCountofSchool > 1 &&
      !shiftSchedule.noonEntranceCompletion
    ) {
      shiftName = "Öğlen Giriş";
      students = await Student.find({
        _id: { $in: bus.students },
        school: school._id,
        schoolStartTime: 1,
      });
    } else if (shiftCountofSchool > 1 && !shiftSchedule.noonExitCompletion) {
      shiftName = "Öğlen Çıkış";
      students = await Student.find({
        _id: { $in: bus.students },
        school: school._id,
        schoolStartTime: 0,
      });
    } else if (!shiftSchedule.eveningExitCompletion) {
      shiftName = "Akşam Çıkış";
      if (shiftCountofSchool == 1) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 2,
        });
      } else if (shiftCountofSchool == 2) {
        students = await Student.find({
          _id: { $in: bus.students },
          school: school._id,
          schoolStartTime: 1,
        });
      }
    } else {
      return res
        .status(400)
        .json({ msg: "Shift are already completed for this school." });
    }
    */

    let startOfDay = new Date();
    startOfDay.setUTCHours(0, 0, 0, 0);

    let endOfDay = new Date();
    endOfDay.setUTCHours(23, 59, 59, 999);

    let studentCount = students.length;
    let permissionCount = 0;
    let studentsInit = await Promise.all(
      students.map(async (student) => {
        let permission = await viewStudentsPermissionsFunction(
          student._id,
          shiftName,
          startOfDay,
          endOfDay
        );
        return {
          student: student._id,
          studentsOrder:
            permission.length != 0
              ? studentCount + permissionCount++
              : shiftName === "Sabah Giriş" || shiftName === "Öğlen Giriş"
              ? student.orderByDriverH2S
              : student.orderByDriverS2H,
          attendanceStatus: permission.length === 0 ? 100 : 300,
          attendanceDescription:
            permission.length === 0 ? "Beklemede" : "İzinli",
        };
      })
    );

    const students_sorted = studentsInit.sort(
      (firstItem, secondItem) =>
        firstItem.studentsOrder - secondItem.studentsOrder
    );

    const shiftInfo = {
      driverPhone: driverPhone,
      school: school._id,
      bus: bus._id,
      shiftName: shiftName,
      students: students_sorted,
      driver: driver._id,
    };

    let shift = new Shift(shiftInfo);

    let location = new Location({
      lat: 0,
      lon: 0,
      shift: shift._id,
    });

    await location.save();

    shift.currentLocation = location._id;

    await shift.save();

    let ids = students_sorted.map((s) => {
      return s.student;
    });

    await Student.updateMany(
      { _id: { $in: ids } },
      { $set: { currentShift: shift.id, onShift: true } }
    );

    if (shiftName == "Sabah Giriş") {
      shiftSchedule.morningEntranceStarted = true;
    } else if (shiftName == "Öğlen Giriş") {
      shiftSchedule.noonEntranceStarted = true;
    } else if (shiftName == "Öğlen Çıkış") {
      shiftSchedule.noonExitStarted = true;
    } else {
      shiftSchedule.eveningExitStarted = true;
    }

    await shiftSchedule.save();

    return res.status(201).json({
      msg: "Shift is created.",
      shiftID: shift._id,
    });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send("Server Error: " + error);
  }
};

/**
 *
 * @param {*} req
 * @param {*} res
 * @returns student name, payment status,
 * attendance description, and çağrı atılmalı mı
 */
module.exports.getShift = async (req, res) => {
  const { shiftID } = req.body;
  try {
    const shift = await Shift.findById(shiftID).populate({
      path: "students",
      populate: {
        path: "student",
      },
    });

    if (!shift) {
      return res.status(404).send({ msg: "Shift not found using given ID" });
    }

    let callButton =
      shift.shiftName === "Sabah Giriş" || shift.shiftName === "Öğlen Giriş"
        ? true
        : false;

    let isActive = !shift.endTime ? true : false;
    let shiftInfo = {
      shiftID: shift._id,
      shiftName: shift.shiftName,
      studentCount: shift.students.length,
      isActive: isActive,
      shiftStartedAt: shift.startTime,
      shiftEndedAt: shift.lastStudentTakenAt,
      endShiftTime: shift.endTime,
      pickedStudentCount:
        shift.students.length -
        shift.students.filter((s) => s.attendanceDescription === "Beklemede")
          .length,
      students: await Promise.all(
        shift.students.map(async (element) => {
          return {
            studentID: element.student.id,
            studentName: element.student.name,
            getOnTime: element.getOnTime,
            getOffTime: element.getOffTime,
            class: element.student.class,
            callButton:
              !isActive ? false : 
              (element.attendanceDescription === "İzinli"
                ? false
                : element.student.class < 2
                ? true
                : callButton ),
            attendanceDescription: element.attendanceDescription,
            paymentStatus: await getSingleStudentPaymentStatus(
              element.student.id,
              shift.driverPhone
            ),
          };
        })
      ),
    };

    return res.status(200).json(shiftInfo);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

/**
 *
 * @param {*} req
 * @param {*} res
 * @returns student name, payment status,
 * attendance description, and çağrı atılmalı mı
 */
module.exports.getShiftFunction = async (shiftID, res) => {
  try {
    const shift = await Shift.findById(shiftID).populate({
      path: "students",
      populate: {
        path: "student",
      },
    });

    if (!shift) {
      return res.status(404).send({ msg: "Shift not found using given ID" });
    }

    let callButton =
      shift.shiftName === "Sabah Giriş" || shift.shiftName === "Öğlen Giriş"
        ? true
        : false;

    let shiftInfo = {
      shiftID: shift._id,
      shiftName: shift.shiftName,
      studentCount:
        shift.students.length -
        shift.students.filter((s) => s.attendanceDescription === "İzinli")
          .length,
      isActive: !shift.endTime ? true : false,
      shiftStartedAt: shift.startTime,
      shiftEndedAt: shift.lastStudentTakenAt,
      endShiftTime: shift.endTime,
      pickedStudentCount:
        shift.students.length -
        shift.students.filter((s) => s.attendanceDescription === "Beklemede")
          .length,
      students: await Promise.all(
        shift.students.map(async (element) => {
          return {
            studentID: element.student.id,
            studentName: element.student.name,
            getOnTime: element.getOnTime,
            getOffTime: element.getOffTime,
            class: element.student.class,
            callButton:
              element.attendanceDescription === "İzinli"
                ? false
                : element.student.class < 2
                ? true
                : callButton,
            attendanceDescription: element.attendanceDescription,
            paymentStatus: await getSingleStudentPaymentStatus(
              element.student.id,
              shift.driverPhone
            ),
          };
        })
      ),
    };

    return res.status(200).json(shiftInfo);
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

// Create shiftSchedule for school-driver pair.
// For testing purposes only - güliş
module.exports.createShiftSchedule = async (req, res) => {
  const { driverPhone, schoolID } = req.body;
  try {
    const driver = await Driver.findOne({ phone: driverPhone });
    const shiftSchedule = new ShiftSchedule({
      driver: driver._id,
      school: schoolID,
    });

    await shiftSchedule.save();
    return res.status(200).json(shiftSchedule);
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

/**
 *
 * @param {*} req
 * @param {*} res
 * @returns Student status updated as evden alındı,beklendi alındı etc.
 */
module.exports.updateStudentStatus = async (req, res) => {
  const { shiftID, studentID, status } = req.body;
  try {

    let isLastStudent = true;
    let statusCode = statusMap.get(status);

    let setPart = {
      $set: {
        [`students.$[outer].attendanceDescription`]: status,
        [`students.$[outer].attendanceStatus`]: statusMap.get(status),
      },
    };

    if ([200, 201, 400, 401].includes(statusCode)) {
      setPart = { ...setPart, [`students.$[outer].getOnTime`]: new Date() };
    }

    if ([500, 501].includes(statusCode)) {
      setPart = { ...setPart, [`students.$[outer].getOffTime`]: new Date() };
    }

    if ([200, 201, 400, 401, 500, 501].includes(statusCode)) {
      let shift = await Shift.findById(shiftID);
      let driver = await User.findOne({ phone: shift?.driverPhone });
      let student = await Student.findById(studentID).populate("school");

      let parentDailyFlowEntry = new ParentDailyFlowEntry({
        entryType: "shift",
        mainHeader: status,
        detailedDescription:
          "Sürücü: " +
          driver.name +
          " | Tarih: " +
          shift.startTime.toISOString().split("T")[0],
        date: new Date(),
        summary: shift.shiftName.split(" ")[1],
        student: student,
        parent: student.parent,
      });

      await parentDailyFlowEntry.save();
    }

    Shift.findOneAndUpdate(
      { _id: shiftID },
      setPart,
      {
        arrayFilters: [{ "outer.student": studentID }],
      },
      function (err, response) {
        if (err) res.status(500).send({ msg: "Server Error: " + err });
      }
    );

    try {
      let shift = await Shift.findById(shiftID);
      let student = await Student.findById(studentID).populate("school");
      if ([301, 401].includes(statusCode)) {
        const agendaEntry = new AgendaEntry({
          driver: shift.driverPhone,
          shift: shiftID,
          agendaEntryType: "ABSENCE",
          mainHeader: student.name,
          summary: shift.shiftName + " alınmadı.",
          detailedDescription: student.school.name + "\nÖğrenci gelmedi",
        });

        await agendaEntry.save();
      }
    } catch (error) {
      logtail.error("updateStudentStatus: Agenda Entry could not be saved.");
      logtail.flush();
      console.log("updateStudentStatus: Agenda Entry could not be saved.");
    }

    let shift = await Shift.findById(shiftID);

    for(let student of shift.students){
      if(student.attendanceStatus === 100 ){
        isLastStudent = false;
      }
    }

    if(isLastStudent){
      shift.lastStudentTakenAt = new Date();
      await shift.save();
    }

    return res
      .status(200)
      .json({ msg: "Student status is updated successfully." });
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.endShift = async (req, res) => {
  const { shiftID } = req.body;
  try {
    const shift = await Shift.findById(shiftID);
    const driver = await Driver.findOne({ phone: shift.driverPhone });

    let now = new Date();
    let startOfToday = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate()
    );

    let shiftSchedule = await ShiftSchedule.findOne({
      driver: driver._id,
      school: shift.school,
      date: { $gte: startOfToday },
    });

    let flag = shift.students.some(
      (student) => student.attendanceStatus === 100
    );

    if (flag) {
      return res.status(400).json({
        msg: "Shift cannot be completed, there is at least one student remaining 'Beklemede' status",
      });
    }

    if (shift.shiftName === "Sabah Giriş") {
      shiftSchedule.morningEntranceCompletion = true;

      let school = await School.findById(shift.school);

      try {
        let schoolEntryDate = toDate(school.firstEntranceTime, "h:m");

        if (now.getTime() > schoolEntryDate.getTime()) {
          shift.lateEntrance = true;
        }
      } catch (error) {
        console.error(error.message);
      }
      
      shiftSchedule.morningEntranceCompletionTime = new Date();
    } else if (shift.shiftName === "Öğlen Çıkış") {
      shiftSchedule.noonExitCompletion = true;
      shiftSchedule.noonExitCompletionTime = new Date();
    } else if (shift.shiftName === "Öğlen Giriş") {
      let school = await School.findById(shift.school);

      try {
        let schoolEntryDate = toDate(school.secondEntranceTime, "h:m");

        if (now.getTime() > schoolEntryDate.getTime()) {
          shift.lateEntrance = true;
        }
      } catch (error) {
        console.error(error.message);
      }
      shiftSchedule.noonEntranceCompletion = true;
      shiftSchedule.noonEntranceCompletionTime = new Date();
    } else if (shift.shiftName === "Akşam Çıkış") {
      shiftSchedule.eveningExitCompletion = true;
      shiftSchedule.eveningExitCompletionTime = new Date();
    }
    shift.endTime = new Date();
    await shift.save();

    let ids = shift.students.map((s) => {
      return s.student;
    });

    await Student.updateMany(
      { _id: { $in: ids } },
      { $set: { onShift: false } }
    );

    if (["Sabah Giriş", "Öğlen Giriş"].includes(shift.shiftName)) {
      Shift.findOneAndUpdate(
        { _id: shiftID },
        {
          $set: {
            [`students.$[outer].getOffTime`]: new Date(),
          },
        },
        {
          arrayFilters: [
            {
              $and: [
                {
                  "outer.attendanceStatus": {
                    $nin: [100, 300, 301, 401],
                  },
                },
              ],
            },
          ],
        },
        function (err, response) {
          if (err) res.status(500).send({ msg: "Server Error: " + err });
        }
      );
    }
    await shiftSchedule.save();

    return res.status(200).json({ msg: "Shift completed successfully." });
  } catch (error) {
    console.error(error.message);
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

function toDate(dStr, format) {
  var now = new Date();
  if (format == "h:m") {
    now.setHours(dStr.substr(0, dStr.indexOf(":")));
    now.setMinutes(dStr.substr(dStr.indexOf(":") + 1));
    now.setSeconds(0);
    return now;
  } else return "Invalid Format";
}
