const { default: mongoose } = require("mongoose");
const Payment = require("../../models/payment");
const Student = require("../../models/student");
const School = require("../../models/school");
const { Driver } = require("../../models/user");
const AgendaEntry = require("../../models/agendaEntry");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");
let monthMap = new Map();
monthMap.set(1, "Ocak");
monthMap.set(2, "Şubat");
monthMap.set(3, "Mart");
monthMap.set(4, "Nisan");
monthMap.set(5, "Mayıs");
monthMap.set(6, "Haziran");
monthMap.set(7, "Temmuz");
monthMap.set(8, "Ağustos");
monthMap.set(9, "Eylül");
monthMap.set(10, "Ekim");
monthMap.set(11, "Kasım");
monthMap.set(12, "Aralık");
//fraction eğer ki öğrenci ayın ortasında geldiyse bir aylık ödemeyecek küsuratlı ödeyecek onun için gerekli
//fraction'da küsurat hesaplanmış olarak tl cinsiden gelir
module.exports.addPayment = async (
  yearly,
  period_in_month,
  charge,
  studentID,
  dueDate,
  phone,
  fraction
) => {
  try {
    let total_charge = yearly ? period_in_month * charge : charge;

    const driver = await Driver.find({ phone: phone });
    if (!driver) {
      return false;
    }

    let query = {
      paidAmount: 0,
      leftAmount: total_charge,
      paidTo: phone,
      paidBy: studentID,
      dueDate: dueDate,
      originalDueDate: dueDate,
      originalAmount: total_charge,
    };

    let payment;
    if (yearly) {
      query.leftAmount += fraction;
      query.installment = 1;
      query.totalInstallment = 1;
      payment = new Payment(query);
      await payment.save();
    } else {
      query.totalInstallment = period_in_month;
      for (let i = 0; i < period_in_month; i++) {
        query.installment = i + 1;

        if (i == 0) {
          query.leftAmount += fraction;
        }

        payment = new Payment(query);
        await payment.save();
        query.leftAmount = total_charge;
        let tempDate = new Date(query.dueDate);
        tempDate.setMonth(tempDate.getMonth() + 1);
        query.dueDate = tempDate;
        query.originalDueDate = tempDate;
      }
    }

    return true;
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.log(error);
    return false;
  }
};

/**
 * This actually corresponds to tahsilat gir, you send payment id and
 * paid amount, the payment is updated and if necessary becomes "paid"
 * payments will be automatically set to "late" in index.js
 * @param {*} req -> (id, paid)
 * @param {*} res
 * @returns a success message
 */
module.exports.updatePayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.body.id).populate("paidBy");

    if (!payment) {
      return res.status(404).send({ msg: "No payment with id." });
    }

    let paid =
      req.body.paid > payment.leftAmount ? payment.leftAmount : req.body.paid;

    payment.paidAmount += parseInt(paid);
    payment.leftAmount -= parseInt(paid);

    if (payment.leftAmount == 0) {
      payment.paymentStatus = "paid";
      payment.statusChange = new Date();
    }
    payment.lastUpdate = new Date();

    let student = await Student.findById(payment.paidBy).populate("school");

    const agendaEntry = new AgendaEntry({
      driver: payment.paidTo,
      payment: payment._id,
      agendaEntryType: "PAYMENT",
      mainHeader: student.name,
      summary: paid + "₺ Gelir",
      detailedDescription: student.school.name + "\nÖğrenci Tahsilatı",
    });

    await agendaEntry.save();

    await payment.save();
    return res.status(200).send({ msg: "Payment is updated successfully." });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.postponePayment = async (req, res) => {
  try {
    const { id, postponeAmount } = req.body;

    const payment = await Payment.findById(id);
    payment.lastUpdate = new Date();
    payment.dueDate.setMonth(payment.dueDate.getMonth() + postponeAmount);
    payment.paymentStatus = "postponed";
    payment.statusChange = new Date();
    await payment.save();

    let student = await Student.findById(payment.paidBy).populate("school");
    const agendaEntry = new AgendaEntry({
      driver: payment.paidTo,
      payment: payment._id,
      agendaEntryType: "POSTPONE",
      mainHeader: student.name,
      summary: "Ödeme ertelendi.",
      detailedDescription: student.school.name + "\nÖdeme Erteleme",
    });

    await agendaEntry.save();

    return res.status(200).send({ msg: "Payment is postponed successfully" });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.viewPayments = async (req, res) => {
  try {
    let compare_begin = req.body.fromDate;
    let compare_end = req.body.toDate;

    const driver = await Driver.findOne({ phone: req.body.phone }).populate(
      "bus"
    );
    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }
    let busStudents = driver.bus.students;

    let query_find_student = {
      school: req.body.school,
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
      paidTo: req.body.phone,
      paidBy: { $in: students_ids },
      dueDate: { $gte: compare_begin, $lte: compare_end },
    };

    const payments = await Payment.find(query).populate("paidBy");

    if (!payments) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "There is not any payment." });
    }

    payments_mapped = payments.map((payment) => {
      return {
        _id: payment._id,
        paidTo: payment.paidTo,
        paidBy: payment.paidBy.name,
        paidAmount: payment.paidAmount,
        leftAmount: payment.leftAmount,
        lastUpdate: payment.lastUpdate,
        dueDate: payment.dueDate,
        originalDueDate: payment.originalDueDate,
        statusChange: payment.statusChange,
        paymentStatus: payment.paymentStatus,
        paymentNumber: payment.installment + "/" + payment.totalInstallment,
      };
    });

    return res.status(200).send(payments_mapped);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

// This method should also show postponed payments in that month
module.exports.viewUnpaidPayments = async (req, res) => {
  try {
    let compare_begin = req.body.fromDate;
    let compare_end = req.body.toDate;

    const driver = await Driver.findOne({ phone: req.body.phone }).populate(
      "bus"
    );
    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }
    let busStudents = driver.bus.students;

    let query_find_student = {
      school: req.body.school,
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
      paidTo: req.body.phone,
      paidBy: { $in: students_ids },
      dueDate: { $gte: compare_begin, $lte: compare_end },
      leftAmount: { $gt: 0 },
    };

    const payments = await Payment.find(query).populate("paidBy");

    if (!payments) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "There is not any payment." });
    }

    payments_mapped = payments.map((payment) => {
      return {
        _id: payment._id,
        paidTo: payment.paidTo,
        paidBy: payment.paidBy.name,
        paidAmount: payment.paidAmount,
        leftAmount: payment.leftAmount,
        lastUpdate: payment.lastUpdate,
        dueDate: payment.dueDate,
        statusChange: payment.statusChange,
        paymentStatus: payment.paymentStatus,
        paymentNumber: payment.installment + "/" + payment.totalInstallment,
      };
    });

    return res.status(200).send(payments_mapped);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

/**
 *
 * @param {*} req
 * @param {*} res
 * @returns payment status
 * example output format: "Ertelendi", "Ödenmedi", "Ertelendi, Ödenmedi"
 */
module.exports.getSingleStudentPaymentStatus = async (
  studentID,
  driverPhone
) => {
  const studentRecord = await Payment.find({
    paidBy: studentID,
    paidTo: driverPhone,
  });

  let res = studentRecord.some(
    (student) => student.paymentStatus === "postponed"
  )
    ? "Ertelendi"
    : "";

  res = studentRecord.some((student) => student.paymentStatus === "late")
    ? res === ""
      ? "Gecikti"
      : res + ", Gecikti"
    : res;

  if (res === "") {
    res = "Yok";
  }

  return res;
};

/** *
 * @param {*} req
 * @param {*} res
 * @returns total expected income, income and amount to be collected
 */
module.exports.calculateIncomeBySchool = async (req, res) => {
  try {
    let compare_begin = req.body.fromDate;
    let compare_end = req.body.toDate;

    const driver = await Driver.findOne({ phone: req.body.phone }).populate(
      "bus"
    );
    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }

    let busStudents = driver.bus.students;

    let query_find_student_by_school = {
      school: req.body.school,
      _id: { $in: busStudents },
    };
    const students = await Student.find(query_find_student_by_school);

    if (!students) {
      return res.status(404).send({
        success: false,
        errorMsg: "No students returned.",
      });
    }

    let s = await School.findById(req.body.school);
    let students_ids = students.map((student) => {
      return student._id;
    });

    let result = await Payment.aggregate([
      {
        $match: {
          paidTo: req.body.phone,
          paidBy: { $in: students_ids },
          dueDate: {
            $gte: new Date(compare_begin),
            $lte: new Date(compare_end),
          },
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
          paidTo: req.body.phone,
          paidBy: { $in: busStudents },
          dueDate: {
            $gte: new Date(compare_begin),
            $lte: new Date(compare_end),
          },
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

    return res.status(200).json({
      totalExpectedIncome: result[0]?.totalExpectedIncome,
      totalIncomeSoFar: result[0]?.totalIncomeSoFar,
      amountToBeCollected: result[0]?.amountToBeCollected,
      schoolName: s.name,
      totalExpectedIncomeAllSchools: result_all[0]?.totalExpectedIncome,
    });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
//tahsilat iste alt kısımdaki zamanzingo
//tüm okullar gelir, tüm okullar tahislat, tüm okullar ödeyecekler
module.exports.calculateIncome = async (req, res) => {
  try {
    let compare_begin = req.body.fromDate;
    let compare_end = req.body.toDate;

    const driver = await Driver.findOne({ phone: req.body.phone }).populate(
      "bus"
    );
    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }

    let busStudents = driver.bus.students;

    let result = await Payment.aggregate([
      {
        $match: {
          paidTo: req.body.phone,
          paidBy: { $in: busStudents },
          dueDate: {
            $gte: new Date(compare_begin),
            $lte: new Date(compare_end),
          },
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

    return res.status(200).json(result);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getFinancialAgenda = async (req, res) => {
  // Only returns top 10 agenda entries
  try {
    const agendaEntries = await AgendaEntry.find({
      driver: req.body.driverPhone,
      agendaEntryType: { $in: ["EXPENSE", "PAYMENT", "SEND_IBAN", "POSTPONE"] },
    })
      .select({
        _id: 1,
        mainHeader: 1,
        summary: 1,
        detailedDescription: 1,
        date: 1,
        agendaEntryType: 1,
      })
      .sort({ date: "desc" })
      .limit(5);
    return res.status(200).send(agendaEntries);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.addAdditionalPayment = async (req, res) => {
  try {
    const { studentID, driverPhone, amount, dueDate } = req.body;

    let payment = new Payment({
      paidBy: studentID,
      paidTo: driverPhone,
      leftAmount: amount,
      paidAmount: 0,
      installment: 0,
      totalInstallment: 0,
      additional: true,
      originalAmount: amount,
      dueDate: dueDate,
    });

    await payment.save();
    return res.status(200).send(payment);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.makeRaise = async (req, res) => {
  const { studentID, driverPhone, raiseAmount } = req.body;

  Payment.updateMany(
    {
      paidBy: studentID,
      paidTo: driverPhone,
      additional: false,
      paymentStatus: "unpaid",
    },
    {
      $inc: {
        leftAmount: raiseAmount,
      },
    },
    { new: true }
  )
    .then(() => {
      return res.status(200).send({ msg: "You successfully made the raise." });
    })
    .catch((error) => {
      console.error(error.message);
      logtail.error(error.message);
      logtail.flush();
      return res.status(500).send({ msg: "Server Error: " + error.message });
    });
};

module.exports.getMakeRaiseInfo = async (req, res) => {
  try {
    const phone = req.user?.phone;
    const studentID = req.body.studentID;

    let payment = await Payment.find({
      paidBy: studentID,
      paidTo: phone,
      additional: false,
      paymentStatus: "unpaid",
    }).sort({ originalDueDate: "asc" });
    payment = payment.at(0);

    let date = new Date(payment.dueDate);
    let student = await Student.findById(req.body.studentID);

    return res.status(200).send({
      paymentPreference: student.paymentPreference,
      whogondothePayment: student.whogondothePayment,
      charge: payment.leftAmount + payment.paidAmount,
      monthsRemaining: payment.totalInstallment - payment.installment,
      start: monthMap.get(date.getMonth() + 1),
      end: monthMap.get(
        ((date.getMonth() +  (payment.totalInstallment - payment.installment)) % 12 ) + 1
      ),
    });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
