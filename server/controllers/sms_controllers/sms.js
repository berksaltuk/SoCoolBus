require("dotenv").config();
const axios = require("axios");
const soap = require("soap");
const Student = require("../../models/student.js");
const Shift = require("../../models/shift.js");
const Addres = "http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl";
const Account = require("../../models/account.js");
const SMS = require("../../models/sms.js");
const AgendaEntry = require("../../models/agendaEntry.js");
const Payment = require("../../models/payment.js");
const { Driver, User } = require("../../models/user.js");
const crypto = require("crypto").webcrypto;

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.shareIBAN = async (req, res) => {
  try {
    let id = req.body.student_id;
    let account_id = req.body.account_id;

    let parentOfStudent = await Student.findById(id).populate("parent");
    let telephone = parentOfStudent.parent.phone;

    let account = await Account.findById(account_id);
    let receiver = account.receiver;
    let iban;
    let msg = "Servis ödemenizi alıcısı " + receiver;
    iban = account.iban;
    msg +=
      " olan " +
      account.bankName +
      " " +
      iban +
      " adresine yapmanız önemle rica olunur.";

    let body = {
      username: process.env.NETGSM_USERNAME,
      password: process.env.NETGSM_PASSWORD,
      header: process.env.NETGSM_MSGHEADER,
      msg: msg,
      gsm: telephone,
      encoding: "TR",
    };

    soap.createClient(Addres, (err, client) => {
      client.smsGonder1NV2(body, (err, result) => {
        if (result) {
          console.log(result);
        }
      });
    });

    let sms = new SMS({
      to: telephone,
      from: req.user.phone,
      msg: msg,
      smsType: "SHARE_IBAN",
    });

    await sms.save();

    const agendaEntry = new AgendaEntry({
      driver: req.user.phone,
      sms: sms._id,
      agendaEntryType: "SEND_IBAN",
      mainHeader: parentOfStudent.name,
      summary: "Hesap bilgileri gönderildi.",
      detailedDescription: "",
    });

    await agendaEntry.save();

    return res
      .status(200)
      .send({ msg: "SMS operation is initiated successfully.", sms: sms });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.gettingCloseSendSMS = async (req, res) => {
  try {
    let id = req.body.student_id;

    let parentOfStudent = await Student.findById(id).populate("parent");
    let telephone = parentOfStudent.parent.phone;
    let studentName = parentOfStudent.name;

    let msg =
      studentName + ", lütfen hazır ol okul servisin evine varmak üzere!";
    let body = {
      username: process.env.NETGSM_USERNAME,
      password: process.env.NETGSM_PASSWORD,
      header: process.env.NETGSM_MSGHEADER,
      msg: msg,
      gsm: telephone,
      encoding: "TR",
    };

    soap.createClient(Addres, (err, client) => {
      client.smsGonder1NV2(body, (err, result) => {
        if (result) {
          console.log(result);
        }
      });
    });

    let sms = new SMS({
      to: telephone,
      from: req.user.phone,
      msg: msg,
      smsType: "GETTING_CLOSE",
    });

    await sms.save();
    return res
      .status(200)
      .send({ msg: "SMS operation is initiated successfully.", sms: sms });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.askForPayment = async (req, res) => {
  try {
    let ids = req.body.paymentIDs.substring(1, req.body.paymentIDs.length - 1);
    ids = ids.split(", ");
    console.log(ids);
    allSMSInfo = [];
    for (let id of ids) {
      let payment = await Payment.findById(id);
      let parentOfStudent = await Student.findById(payment.paidBy).populate(
        "parent"
      );

      let telephone = parentOfStudent.parent.phone;
      let studentName = parentOfStudent.name;

      let msg =
        studentName +
        " adlı öğrencimizin " +
        payment.leftAmount +
        " TL tutarındaki " +
        payment.dueDate.toISOString().slice(0, 10) +
        " son ödeme tarihli ödemesini yapmanızı rica ederiz.";
      let body = {
        username: process.env.NETGSM_USERNAME,
        password: process.env.NETGSM_PASSWORD,
        header: process.env.NETGSM_MSGHEADER,
        msg: msg,
        gsm: telephone,
        encoding: "TR",
      };

      soap.createClient(Addres, (err, client) => {
        console.log(err);
        client.smsGonder1NV2(body, (err, result) => {
          console.log(result);
          console.log(body);
          if (result) {
            console.log(result);
          }
        });
      });

      let sms = new SMS({
        to: telephone,
        from: req.user.phone,
        msg: msg,
        smsType: "ASK_FOR_PAYMENT",
      });

      const agendaEntry = new AgendaEntry({
        driver: req.user.phone,
        sms: sms._id,
        payment: payment._id,
        agendaEntryType: "ASK_FOR_PAYMENT",
        mainHeader: parentOfStudent.name,
        summary: "Ödeme istendi.",
        detailedDescription: "",
      });
      await agendaEntry.save();

      await sms.save();
      allSMSInfo.push(sms);
    }
    return res.status(200).send({
      msg: "SMS operation is initiated successfully.",
      sms: allSMSInfo,
    });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.sendLoginInformation = async (phone, password, driverPhone) => {
  try {
    let msg =
      "Sayın velimiz, Servisyolum'a hoş geldiniz. Uygulamaya " +
      password +
      " şifrenizle giriş yapabilirsiniz.";
    let body = {
      username: process.env.NETGSM_USERNAME,
      password: process.env.NETGSM_PASSWORD,
      header: process.env.NETGSM_MSGHEADER,
      msg: msg,
      gsm: phone,
      encoding: "TR",
    };

    soap.createClient(Addres, (err, client) => {
      client.smsGonder1NV2(body, (err, result) => {
        if (result) {
          console.log(result);
        }
      });
    });

    let sms = new SMS({
      to: phone,
      from: driverPhone,
      msg: msg,
      smsType: "SEND_PARENT_PASSWORD",
    });

    await sms.save();

    return true;
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return false;
  }
};

module.exports.sendNewPassword = (phone, password) => {
  try {
    let msg = "Uygulamaya " + password + " şifrenizle giriş yapabilirsiniz.";
    let body = {
      username: process.env.NETGSM_USERNAME,
      password: process.env.NETGSM_PASSWORD,
      header: process.env.NETGSM_MSGHEADER,
      msg: msg,
      gsm: phone,
      encoding: "TR",
    };

    soap.createClient(Addres, (err, client) => {
      client.smsGonder1NV2(body, (err, result) => {
        if (result) {
          console.log(result);
        }
      });
    });
    return true;
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return false;
  }
};

module.exports.sendCustomMessage = (phone, msg) => {
  try {
    let body = {
      username: process.env.NETGSM_USERNAME,
      password: process.env.NETGSM_PASSWORD,
      header: process.env.NETGSM_MSGHEADER,
      msg: msg,
      gsm: phone,
      encoding: "TR",
    };

    soap.createClient(Addres, (err, client) => {
      client.smsGonder1NV2(body, (err, result) => {
        if (result) {
          console.log(result);
        }
      });
    });
    return true;
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return false;
  }
};

module.exports.callParent = async (req, res) => {
  // TO DO
  try {
    const { studentID, shiftID } = req.body;

    let shift = await Shift.findById(shiftID);
    let student = await Student.findById(studentID).populate("parent");
    let driver = await User.findOne({ phone: shift?.driverPhone });
    let parentPhone = student?.parent?.phone;
    let shiftName = shift?.shiftName;

    let parentDailyFlowEntry = new ParentDailyFlowEntry({
      entryType: "shift",
      mainHeader: "Çağrı Atıldı",
      detailedDescription:
        "Sürücü: " +
        driver.name +
        "| Tarih: " +
        shift.startTime.toISOString().split("T")[0],
      date: new Date(),
      summary: shift.shiftName.split(" ")[1],
      student: student,
      parent: student.parent,
    });

    await parentDailyFlowEntry.save();

    let crm_id = crypto.randomUUID();
    let url =
      "http://crmsntrl.netgsm.com.tr:9111/" +
      process.env.NETGSM_USERNAME +
      "/originate?username=" +
      process.env.NETGSM_USERNAME +
      "&password=" +
      process.env.NETGSM_PASSWORD +
      "&customer_num=" +
      parentPhone +
      "&pbxnum=" +
      process.env.NETGSM_USERNAME +
      "&internal_num=" +
      (shiftName == "Öğlen Çıkış" || shiftName == "Akşam Çıkış"
        ? process.env.OGRENCI_YAKLASIYOR
        : process.env.SERVIS_YAKLASIYOR) +
      "&ring_timeout=20&crm_id=" +
      crm_id +
      "&wait_response=0&originate_order=of&trunk=" +
      process.env.NETGSM_USERNAME;
    console.log(url);

    axios
      .get(url)
      .then(function (response) {
        return res.status(200).send({ msg: "Call is initiated successfully." });
      })
      .catch(function (error) {
        logtail.error("Server Error:" + error.message);
        logtail.flush();
        return res.status(500).send({ msg: "Server Error: " + error.message });
      });
  } catch (error) {
    logtail.error("Server Error:" + error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
