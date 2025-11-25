// Driver Reports
const { default: mongoose } = require("mongoose");
const PDFDocument = require("pdfkit");
const Payment = require("../../models/payment");
const Student = require("../../models/student");
const { Driver } = require("../../models/user");
const Expense = require("../../models/expense");
const School = require("../../models/school");
const Shift = require("../../models/shift");
const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

// Financial Reports

/**
 * Give driver phone to retrieve school specific payment details.
 * @param {*} req
 * @param {*} res
 * @returns a list of payment summary
 */
module.exports.incomeReportBySchool = async (req, res) => {
  try {
    const { driverPhone } = req.body;
    let driver = await Driver.findOne({ phone: driverPhone }).populate("bus");
    let studentsOfDriver = driver.bus.students;
    let payments = await Payment.find({
      paidTo: driverPhone,
      paidBy: { $in: studentsOfDriver },
    }).populate({
      path: "paidBy",
    });

    let ids = payments.map((payment) => {
      return mongoose.Types.ObjectId(payment._id);
    });

    let result = await Payment.aggregate([
      {
        $match: {
          _id: {
            $in: ids,
          },
        },
      },

      {
        $group: {
          _id: "$paidBy",
          total: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
          paidAmount: {
            $sum: "$paidAmount",
          },
          leftAmount: {
            $sum: "$leftAmount",
          },
          paidBy: { $first: "$paidBy" },
          totalInstallment: { $first: "$totalInstallment" },
        },
      },
      {
        $lookup: {
          from: "students",
          localField: "paidBy",
          foreignField: "_id",
          as: "student",
        },
      },
      { $unwind: "$student" },
      {
        $project: {
          studentName: "$student.name",
          schoolID: "$student.school",
          total: 1,
          leftAmount: 1,
          paidAmount: 1,
          totalInstallment: 1,
        },
      },
      {
        $group: {
          _id: "$schoolID",
          total: {
            $sum: "$total",
          },
          paidAmount: {
            $sum: "$paidAmount",
          },
          leftAmount: {
            $sum: "$leftAmount",
          },
        },
      },
      {
        $lookup: {
          from: "schools",
          localField: "_id",
          foreignField: "_id",
          as: "school",
        },
      },
      { $unwind: "$school" },
      {
        $project: {
          name: "$school.name",
          serviceTimeInMonths: "$school.serviceTimeInMonths",
          total: 1,
          leftAmount: 1,
          paidAmount: 1,
        },
      },
    ]);

    let busStudents = driver.bus.students;

    let summary = await Payment.aggregate([
      {
        $match: {
          paidTo: driverPhone,
          paidBy: { $in: busStudents },
        },
      },
      {
        $group: {
          _id: null,
          totalExpectedIncome: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
          totalIncomeSoFar: {
            $sum: "$paidAmount",
          },
          amountToBeCollected: {
            $sum: "$leftAmount",
          },
        },
      },
    ]);
    return await res.status(200).json({
      result,
      summary: summary[0],
      reportType: "incomeReportBySchool",
    });
  } catch (e) {
    logtail.error("Something went wrong. Error: " + e.message);
    logtail.flush();
    return res
      .status(500)
      .json({ message: "Something went wrong. Error: " + e.message });
  }
};

/**
 * Give driver phone and school ID to retrieve student specific payment details.
 * @param {*} req
 * @param {*} res
 * @returns a list of payment summary
 */
module.exports.incomeReportByStudent = async (req, res) => {
  try {
    const { driverPhone, schoolID } = req.body;
    let driver = await Driver.findOne({ phone: driverPhone }).populate("bus");
    let studentsOfDriver = driver.bus.students;
    let school = await School.findById(schoolID);
    let payments = await Payment.find({
      paidTo: driverPhone,
      paidBy: { $in: studentsOfDriver },
    }).populate({
      path: "paidBy",
      populate: {
        path: "school",
      },
    });

    payments = payments.filter(
      (payment) => payment.paidBy?.school?.id == schoolID
    );

    let ids = payments.map((payment) => {
      return mongoose.Types.ObjectId(payment._id);
    });

    let result = await Payment.aggregate([
      {
        $match: {
          _id: {
            $in: ids,
          },
        },
      },

      {
        //select sum(leftAmount + paidAmount) as total, sum(paidAmount) as paidAmount, sum(leftAmount) as leftAmount from Payment
        //where id in payments.id group by paidBy
        $group: {
          _id: "$paidBy",
          total: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
          paidAmount: {
            $sum: "$paidAmount",
          },
          leftAmount: {
            $sum: "$leftAmount",
          },
          paidBy: { $first: "$paidBy" },
          serviceTimeInMonths: { $first: "$totalInstallment" },
        },
      },
      {
        $lookup: {
          from: "students",
          localField: "paidBy",
          foreignField: "_id",
          as: "student",
        },
      },
      { $unwind: "$student" },
      {
        $project: {
          name: "$student.name",
          active: "$student.active",
          total: 1,
          leftAmount: 1,
          paidAmount: 1,
          serviceTimeInMonths: 1,
        },
      },
    ]);

    let busStudents = driver.bus.students;

    let query_find_student_by_school = {
      school: schoolID,
      _id: { $in: busStudents },
    };
    const students = await Student.find(query_find_student_by_school);

    if (!students) {
      return res.status(404).send({
        success: false,
        errorMsg: "No students returned.",
      });
    }

    let s = await School.findById(schoolID);
    let students_ids = students.map((student) => {
      return student._id;
    });

    let sum = await Payment.aggregate([
      {
        $match: {
          paidTo: driverPhone,
          paidBy: { $in: students_ids },
        },
      },
      {
        $group: {
          _id: null,
          totalExpectedIncome: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
          totalIncomeSoFar: {
            $sum: "$paidAmount",
          },
          amountToBeCollected: {
            $sum: "$leftAmount",
          },
        },
      },
    ]);

    let result_all = await Payment.aggregate([
      {
        $match: {
          paidTo: driverPhone,
          paidBy: { $in: busStudents },
        },
      },
      {
        $group: {
          _id: null,
          totalExpectedIncome: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
        },
      },
    ]);

    let summary = {
      totalExpectedIncome: sum[0]?.totalExpectedIncome,
      totalIncomeSoFar: sum[0]?.totalIncomeSoFar,
      amountToBeCollected: sum[0]?.amountToBeCollected,
      schoolName: s.name,
      totalExpectedIncomeAllSchools: result_all[0]?.totalExpectedIncome,
    };

    return await res.status(200).json({
      result,
      summary,
      schoolName: school.name,
      reportType: "incomeReportByStudent",
    });
  } catch (e) {
    logtail.error("Something went wrong. Error: " + e.message);
    logtail.flush();
    return res
      .status(500)
      .json({ message: "Something went wrong. Error: " + e.message });
  }
};

module.exports.expenseReport = async (req, res) => {
  try {
    const { driverPhone, fromDate, toDate } = req.body;

    let expenses = await Expense.find(
      {
        phone: driverPhone,
        date: { $gte: fromDate, $lte: toDate },
      },
      { expenseType: 1, amount: 1, date: 1, description: 1 }
    );

    let summary = await Expense.aggregate([
      {
        $match: {
          phone: driverPhone,
          date: { $gte: new Date(fromDate), $lte: new Date(toDate) },
        },
      },
      {
        $group: {
          _id: "$expenseType",

          totalAmount: {
            $sum: "$amount",
          },
        },
      },
    ]);

    return res.status(200).json({
      result: expenses,
      summary: summary,
      reportType: "expenseReport",
      from: fromDate.split("T")[0],
      to: toDate.split("T")[0],
    });
  } catch (e) {
    logtail.error("Something went wrong. Error: " + e.message);
    logtail.flush();
    return res
      .status(500)
      .json({ message: "Something went wrong. Error: " + e.message });
  }
};

// PDF
module.exports.generatePDF = async (req, res) => {
  try {
    const doc = new PDFDocument({ margin: 50 });

    let { payload } = req.body;
    payload = JSON.parse(payload);
    console.log(payload);

    // Pipe its output somewhere, like to a file or HTTP response
    // See below for browser usage
    doc
      .image("img/logo.jpeg", 50, 45, { width: 100 })
      .fillColor("#444444")
      .moveDown();
    let reportType = payload.reportType;
    console.log(reportType);
    doc.font("fonts/Roboto-Bold.ttf");
    if (reportType == "incomeReportBySchool") {
      doc.text("Okul Bazlı Gelir Raporu", 50, 175);
      generateHr(doc, 200);

      generateTableRow(
        doc,
        250,
        "Toplam",
        "Tahsilat",
        "Kalan Tahsilat",
        "",
        ""
      );

      generateTableRow(
        doc,
        280,
        payload.summary.totalExpectedIncome,
        payload.summary.totalIncomeSoFar,
        payload.summary.amountToBeCollected,
        "",
        ""
      );

      let i,
        invoiceTableTop = 330;

      generateTableRow(
        doc,
        invoiceTableTop,
        "Okul Adı",
        "Ödenen",
        "Ödenecek",
        "Toplam Tutar",
        "Servis Süresi"
      );
      generateHr(doc, invoiceTableTop + 20);
      doc.font("fonts/Roboto-Regular.ttf");
      let c = 0;
      for (i = 0; i < payload.result.length; i++) {
        const item = payload.result[i];

        let position = invoiceTableTop + (c + 1) * 30;
        if (position > 650) {
          c = 0;
          invoiceTableTop = 150;

          position = invoiceTableTop + (c + 1) * 30;
          doc.addPage();

          generateTableRow(
            doc,
            invoiceTableTop,
            "Okul Adı",
            "Ödenen",
            "Ödenecek",
            "Toplam Tutar",
            "Servis Süresi"
          );
          generateHr(doc, invoiceTableTop + 20);
        }

        generateTableRow(
          doc,
          position,
          item.name,
          item.paidAmount + "₺",
          item.leftAmount + "₺",
          item.total + "₺",
          item.serviceTimeInMonths
        );
        c++;
        generateHr(doc, position + 20);
      }
    } else if (reportType == "incomeReportByStudent") {
      doc.text("Okul Bazlı Gelir Raporu", 50, 175);
      generateHr(doc, 200);
      doc.text(`Okul Adı:  ${payload.schoolName}`, 50, 225);

      generateTableRow(
        doc,
        250,
        "Toplam",
        "Tahsilat",
        "Kalan Tahsilat",
        "",
        "Tüm Okullar Kalan Tahsilat"
      );

      generateTableRow(
        doc,
        280,
        payload.summary.totalExpectedIncome,
        payload.summary.totalIncomeSoFar,
        payload.summary.amountToBeCollected,
        "",
        payload.summary.totalExpectedIncomeAllSchools
      );

      let i,
        invoiceTableTop = 330;
      generateTableRow(
        doc,
        invoiceTableTop,
        "Öğrenci Adı",
        "Taşıma Süresi",
        "Ödenen",
        "Ödenecek",
        "Toplam Tutar"
      );
      generateHr(doc, invoiceTableTop + 20);
      doc.font("fonts/Roboto-Regular.ttf");
      let c = 0;
      for (i = 0; i < payload.result.length; i++) {
        const item = payload.result[i];

        let position = invoiceTableTop + (c + 1) * 30;
        if (position > 650) {
          c = 0;
          invoiceTableTop = 150;
          position = invoiceTableTop + (c + 1) * 30;

          doc.addPage();

          generateTableRow(
            doc,
            invoiceTableTop,
            "Öğrenci Adı",
            "Taşıma Süresi",
            "Ödenen",
            "Ödenecek",
            "Toplam Tutar"
          );
          generateHr(doc, invoiceTableTop + 20);
        }

        generateTableRow(
          doc,
          position,
          item.name,
          item.serviceTimeInMonths,
          item.paidAmount + "₺",
          item.leftAmount + "₺",
          item.total + "₺"
        );
        c++;
        generateHr(doc, position + 20);
      }
    } else if (reportType == "expenseReport") {
      doc.text("Şoför Masraf Raporu", 50, 175);
      generateHr(doc, 200);

      doc.text(`Tarih Aralığı:  ${payload.from} | ${payload.to}`, 50, 225);

      generateHr(doc, 250);
      generateTableRow(doc, 280, "Özet", "", "", "", "");
      let summary = "|";
      for (let i = 0; i < payload.summary.length; i++) {
        const item = payload.summary[i];
        summary += item._id + "   -   " + item.totalAmount + "₺ | ";
      }
      doc.text(summary, 50, 300);
      let i,
        invoiceTableTop = 400;
      generateTableRow(
        doc,
        invoiceTableTop,
        "Masraf Tipi",
        "Açıklama",
        "Tutar",
        "Tarih",
        ""
      );
      generateHr(doc, invoiceTableTop + 20);
      doc.font("fonts/Roboto-Regular.ttf");
      let c = 0;
      for (i = 0; i < payload.result.length; i++) {
        const item = payload.result[i];

        let position = invoiceTableTop + (c + 1) * 30;
        if (position > 650) {
          c = 0;
          invoiceTableTop = 150;
          position = invoiceTableTop + (c + 1) * 30;

          doc.addPage();

          generateTableRow(
            doc,
            invoiceTableTop,
            "Masraf Tipi",
            "Açıklama",
            "Tutar",
            "Tarih",
            ""
          );
          generateHr(doc, invoiceTableTop + 20);
        }

        generateTableRow(
          doc,
          position,
          item.expenseType,
          item.description,
          item.amount + "₺",
          item.date.split("T")[0],
          ""
        );
        c++;
        generateHr(doc, position + 20);
      }
    }
    logtail.info("Document Created for " + payload.studentName);
    logtail.flush();
    doc.end();

    doc.pipe(res);
  } catch (error) {
    logtail.error("Something went wrong. Error: " + error.message);
    logtail.flush();
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

function generateTableRow(doc, y, c1, c2, c3, c4, c5) {
  doc
    .fontSize(10)
    .text(c1, 50, y)
    .text(c2, 150, y)
    .text(c3, 280, y, { width: 90, align: "right" })
    .text(c4, 370, y, { width: 90, align: "right" })
    .text(c5, 0, y, { align: "right" });
}

function generateHr(doc, y) {
  doc.strokeColor("#aaaaaa").lineWidth(1).moveTo(50, y).lineTo(550, y).stroke();
}

// School Specific Reports
module.exports.morningEntranceReport = async (req, res) => {
  try {
    const { studentID } = req.body;
    let shifts = await Shift.find();
  } catch (error) {
    return res.status(500).json({ msg: "Server Error: " + error.message });
  }
};

module.exports.eveningExitReport = async (req, res) => {};

// Shift specific Reports
module.exports.schoolBusRouteReport = async (req, res) => {};

module.exports.homeToSchoolShiftReport = async (req, res) => {};

module.exports.schoolToHomeShiftReport = async (req, res) => {};

module.exports.studentRegistrationDatesReport = async (req, res) => {};
