const { CompanyAdmin, User, Driver } = require("../../models/user");
const SchoolBus = require("../../models/schoolBus");
const Student = require("../../models/student");
const Subscription = require("../../models/subscription.js");
const bcrypt = require("bcryptjs");

const { Logtail } = require("@logtail/node");
const { password_generator } = require("../../utilities/password_generator");
const { sendCustomMessage } = require("../sms_controllers/sms");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.viewDriversByCompany = async (req, res) => {
  try {
    const { phone } = req.body;

    const companyAdmin = await CompanyAdmin.findOne({
      phone: phone,
    });

    let companyToken = companyAdmin.companyToken;

    const buses = await SchoolBus.find({
      companyToken: companyToken,
    });

    let busIDs = buses.map((bus) => bus._id);

    let drivers = await Driver.find({ id: { $in: busIDs } });
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

module.exports.getStudentMovementsByCompanyAdmin = async (req, res) => {
  try {
    const { phone } = req.body;

    const companyAdmin = await CompanyAdmin.findOne({
      phone: phone,
    });

    let companyToken = companyAdmin.companyToken;

    const buses = await SchoolBus.find({
      companyToken: companyToken,
    });

    const studentLists = buses.map((bus) => bus.students);

    const studentsMerged = [];

    for (let list of studentLists) {
      studentsMerged = studentsMerged.concat(list);
    }

    const students = await Student.find({
      id: { $in: studentsMerged },
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
    logtail.error(e.message);
    logtail.flush();
    console.error(e.message);
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};

//TO BE CONTINUED
module.exports.getSchoolBusesList = async (req, res) => {
  try {
    const { phone } = req.body;

    const companyAdmin = await CompanyAdmin.findOne({
      phone: phone,
    });

    let companyToken = companyAdmin.companyToken;

    const buses = await SchoolBus.aggregate([
      {
        $match: {
          companyToken: companyToken,
        },
      },
      {
        $lookup: {
          from: "drivers",
          localField: "_id",
          foreignField: "bus",
          pipeline: [
            {
              $lookup: {
                from: "users",
                localField: "_id",
                foreignField: "_id",
                as: "user",
              },
            },
            {
              $unwind: "$user",
            },
          ],
          as: "driver",
        },
      },
      {
        $unwind: {
          path: "$driver",
          preserveNullAndEmptyArrays: true,
        },
      },

      {
        $project: {
          id: "$id",
          name: {
            $cond: {
              if: {
                $eq: [
                  {
                    $ifNull: ["$driver.user.name", ""],
                  },
                  "",
                ],
              },
              then: "Şoför Yok",
              else: "$driver.user.name",
            },
          },
          plate: "$plate",
          companyToken: "$companyToken",
          seatCount: "$seatCount",
          phone: {
            $cond: {
              if: {
                $eq: [
                  {
                    $ifNull: ["$driver.user.phone", ""],
                  },
                  "",
                ],
              },
              then: "Telefon Yok",
              else: "$driver.user.phone",
            },
          },
        },
      },
    ]);

    return res.status(200).json(buses);
  } catch (e) {
    console.error(e.message);
    logtail.error(e.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};
module.exports.addDriverToSchoolBusByCompanyAdmin = async (req, res) => {
  try {
    const { name, phone, tcno, city, schoolBusID } = req.body;
    let user = await User.findOne({ phone: phone });

    if (user && user.canHaveRoles.includes("DRIVER")) {
      logtail.error("User Already Exists");
      logtail.flush();
      return res
        .status(400)
        .json({ errors: [{ msg: "Driver already exists" }] });
    }

    if (!user) {
      let password = password_generator();
      const hashedPassword = await bcrypt.hash(password, 12);
      const userInfo = {
        name: name,
        password: hashedPassword,
        role: "DRIVER",
        phone: phone,
        canHaveRoles: ["DRIVER"],
      };

      user = new User(userInfo);
      let msg =
        "Sayın sürücümüz, Servisyolum'a hoş geldiniz. Uygulamaya " +
        password +
        " şifrenizle giriş yapabilirsiniz.";
      sendCustomMessage(phone, msg);
      await user.save();
    } else {
      user.canHaveRoles.push("DRIVER");
      await user.save();
    }

    const driverUser = new Driver({
      phone: phone,
      bus: schoolBusID,
      schools: [],
      documents: [],
      city: city,
      tcno: tcno,
    });
    driverUser._id = user._id;

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

    await driverUser.save();
    await subscription.save();

    return res.status(200).json({ user, driverUser, subscription });
  } catch (e) {
    logtail.error(e.message);
    logtail.flush();
    console.error(e.message);
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};
module.exports.addSchoolBusByCompanyAdmin = async (req, res) => {
  try {
    const {
      plate,
      busModel,
      muayeneStarts,
      muayeneEnds,
      sigortaStarts,
      sigortaEnds,
      companyAdminPhone,
      seatCount,
    } = req.body;

    let schoolbus = await SchoolBus.findOne({ plate: plate });

    if (schoolbus) {
      return res
        .status(400)
        .json({ msg: "School bus exists with that plate." });
    }

    let company = await CompanyAdmin.findOne({
      phone: companyAdminPhone,
    });
    let companyToken = company.companyToken;
    console.log("token: ", companyToken);

    const bus = new SchoolBus({
      plate: plate,
      seatCount: seatCount,
      secondaryUsers: [],
      students: [],
      companyToken: companyToken,
      busModel: busModel,
      muayeneStarts: muayeneStarts,
      muayeneEnds: muayeneEnds,
      sigortaStarts: sigortaStarts,
      sigortaEnds: sigortaEnds,
    });

    await bus.save();
    return res.status(200).json(bus);
  } catch (e) {
    logtail.error(e.message);
    logtail.flush();
    console.error(e.message);
    return res.status(500).send({ msg: "Server Error: " + e.message });
  }
};
