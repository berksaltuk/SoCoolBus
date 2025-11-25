const Permission = require("../../models/permission.js");
const Student = require("../../models/student.js");
const { User, Driver } = require("../../models/user.js");
const AgendaEntry = require("../../models/agendaEntry.js");
const SchoolBus = require("../../models/schoolBus.js");
const ParentDailyFlowEntry = require("../../models/parentDailyFlowEntry.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.givePermission = async (req, res) => {
  // h2s -> sabah / girişte kullanmayacak
  // s2h -> akşam / çıkışta kullanmayacak
  // both -> iki seferde de kullanmayacak
  try {
    let { studentID, date, phone, permissionType } = req.body;

    let student = await Student.findById(studentID);

    if (!student) {
      return res
        .status(404)
        .send({ msg: "Student is not found with given ID." });
    }

    let shiftName;
    if (permissionType == "h2s") {
      if (student.schoolStartTime == 2) {
        shiftName = ["Sabah Giriş"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Öğlen Giriş"];
      } else {
        shiftName = ["Sabah Giriş"];
      }
    } else if (permissionType == "s2h") {
      if (student.schoolStartTime == 2) {
        shiftName = ["Akşam Çıkış"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Akşam Çıkış"];
      } else {
        shiftName = ["Öğlen Çıkış"];
      }
    } else {
      // both
      if (student.schoolStartTime == 2) {
        shiftName = ["Sabah Giriş", "Akşam Çıkış"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Öğlen Giriş", "Akşam Çıkış"];
      } else {
        shiftName = ["Sabah Giriş", "Öğlen Çıkış"];
      }
    }
    let user = await User.findOne({ phone: phone });

    if (!user) {
      return res
        .status(404)
        .send({ msg: "User is not found with given phone." });
    }

    let perDate = new Date(date);
    perDate.setUTCHours(0, 0, 0, 0);
    perDate.setDate(perDate.getDate() + 1);
    const query = {
      student: studentID,
      permissionGivenBy: user._id,
      date: perDate,
      shiftName: shiftName,
    };

    const permission = new Permission(query);

    await permission.save();

    let parentDailyFlowEntry = new ParentDailyFlowEntry({
      entryType: "shift",
      mainHeader: "İzinli",
      detailedDescription:
        "İzinli Olduğu Servis: " +
        shiftName +
        " | Tarih: " +
        perDate.toISOString().split("T")[0],
      date: new Date(),
      summary: shiftName.map((s) => s.split(" ")[1]).toString(),
      student: student._id,
      parent: student.parent,
    });

    await parentDailyFlowEntry.save();
    return res.status(200).json(permission);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.deletePermission = async (req, res) => {
  try {
    let { permissionID } = req.body;

    let permis = await Permission.findById(permissionID);

    if (!permis) {
      return res
        .status(404)
        .send({ msg: "Permission is not found with given ID." });
    }

    await permis.remove();
    return res.status(200).json({ msg: "permission removed successfully" });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updatePermission = async (req, res) => {
  try {
    let { date, studentID, permissionType, phone } = req.body;

    let permis = await Permission.findOne({
      student: studentID,
      date: { $gte: date },
    });

    if (permissionType == "none") {
      if (permis) {
        try {
          await AgendaEntry.findOneAndRemove({ permission: permis._id });
        } catch (error) {
          console.log("AgendaEntry could not be updated: " + error.message);
        }

        await permis.remove();

        return res
          .status(200)
          .json({ msg: "Permission deleted successfully." });
      }
      return res
        .status(200)
        .json({ msg: "Permission does not exist already." });
    }

    let student = await Student.findById(studentID);

    if (!student) {
      return res
        .status(404)
        .send({ msg: "Student is not found with given ID." });
    }

    let user = await User.findOne({ phone: phone });

    if (!user) {
      return res
        .status(404)
        .send({ msg: "User is not found with given phone." });
    }

    let shiftName;
    if (permissionType == "h2s") {
      if (student.schoolStartTime == 2) {
        shiftName = ["Sabah Giriş"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Öğlen Giriş"];
      } else {
        shiftName = ["Sabah Giriş"];
      }
    } else if (permissionType == "s2h") {
      if (student.schoolStartTime == 2) {
        shiftName = ["Akşam Çıkış"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Akşam Çıkış"];
      } else {
        shiftName = ["Öğlen Çıkış"];
      }
    } else {
      // both
      if (student.schoolStartTime == 2) {
        shiftName = ["Sabah Giriş", "Akşam Çıkış"];
      } else if (student.schoolStartTime == 1) {
        shiftName = ["Öğlen Giriş", "Akşam Çıkış"];
      } else {
        shiftName = ["Sabah Giriş", "Öğlen Çıkış"];
      }
    }

    if (!permis) {
      let perDate = new Date(date);
      perDate.setDate(perDate.getDate() + 1);
      perDate.setUTCHours(0, 0, 0, 0);
      permis = new Permission({
        student: studentID,
        permissionGivenBy: user._id,
        date: perDate,
        shiftName: shiftName,
      });

      try {
        let schoolBus = await SchoolBus.findOne({ students: studentID });
        let driver = await Driver.findOne({ bus: schoolBus._id });
        let student = await Student.findById(studentID).populate("school");
        userType = user.role === "PARENT" ? "Veli" : "Okul";
        const agendaEntry = new AgendaEntry({
          driver: driver.phone,
          permission: permis._id,
          agendaEntryType: "PERMISSION",
          mainHeader: student.name,
          summary: shiftName + " alınmayacak.",
          detailedDescription:
            student.school.name + " / " + userType + ": İzinli",
        });

        await agendaEntry.save();
      } catch (error) {
        logtail.error(error.message);
        logtail.flush();
        console.log("AgendaEntry could not be saved: " + error.message);
      }

      await permis.save();
      return res.status(200).json({
        msg: "Permission is given successfully.",
        permissionDetails: permis,
      });
    }

    permis.shiftName = shiftName;
    await permis.save();

    try {
      await AgendaEntry.findOneAndUpdate(
        { permission: permis._id },
        {
          $set: {
            summary: shiftName + " alınmayacak.",
          },
        }
      );
    } catch (error) {
      logtail.error(error.message);
      logtail.flush();
      console.log("AgendaEntry could not be updated: " + error.message);
    }

    return res.status(200).json({
      msg: "Permission updated successfully.",
      permissionDetails: permis,
    });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.viewStudentsPermissions = async (req, res) => {
  try {
    let { studentID, fromDate, toDate } = req.body;

    const permissions = await Permission.find({
      student: studentID,
      date: { $gte: new Date(fromDate), $lte: new Date(toDate) },
    });
    return res.status(200).json(permissions);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getPermission = async (req, res) => {
  try {
    let { studentID, date } = req.body;

    const permissions = await Permission.findOne({
      student: studentID,
      date: date,
    });
    if (!permissions) {
      return res.status(404).json();
    }
    return res.status(200).json(permissions);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.viewStudentsPermissionsFunction = async (
  studentID,
  shiftName,
  fromDate,
  toDate
) => {
  try {
    const permissions = await Permission.find({
      student: studentID,
      shiftName: shiftName,
      date: { $gte: fromDate, $lte: toDate },
    });
    return permissions;
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return null;
  }
};
