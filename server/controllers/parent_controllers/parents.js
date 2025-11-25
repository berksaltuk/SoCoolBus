const allUsers = require("../../models/user.js");
const { User, Parent } = allUsers;
const Payment = require("../../models/payment.js");
const Address = require("../../models/address.js");

const { geocodingFunc } = require("../maps_controllers/maps.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.updateParentAddress = async (req, res) => {
  let { phone, address, addressDirections } = req.body;
  console.log(req.body);

  try {
    let parent = await Parent.findOne({ phone });
    if (!parent) {
      return res.status(404).json({ msg: "Parent user not found" });
    }

    let addressObj = await Address.findById(parent.address);

    if (address === "") address = addressObj.address;
    if (addressDirections === "")
      addressDirections = addressObj.addressDirections;

    addressObj.address = address;
    addressObj.addressDirections = addressDirections;

    let location = await geocodingFunc(address);

    if (location) {
      let { lat, lng } = location;

      addressObj.lat = lat;
      addressObj.lon = lng;
      addressObj.link =
        "https://www.google.com/maps/search/?api=1&query=" + lat + "," + lng;
    }

    await addressObj.save();
    await parent.save();
    return res.status(200).json({ parent: parent, address: addressObj });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send("Server Error: " + error);
  }
};

module.exports.getParentByPhone = async (req, res) => {
  const { phone } = req.body;
  try {
    let user = await allUsers.Parent.findOne({ phone });
    if (!user) {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(200).json(user);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getChildren = async (req, res) => {
  try {
    const { phone } = req.body;
    let parent = await Parent.findOne({ phone: phone });

    let students = await Student.find({
      _id: { $in: parent.children },
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
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

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

module.exports.getChildrenPayments = async (req, res) => {
  const { parentPhone, month } = req.body;
  try {
    let parent = await Parent.findOne({ phone: parentPhone }).populate(
      "children"
    );
    if (!parent) {
      return res.status(404).json({ msg: "Error: Parent not found" });
    }

    let result = await Payment.aggregate([
      {
        $match: {
          paidBy: { $in: parent.children },
          $expr: {
            $eq: [{ $month: "$dueDate" }, monthMap.get(month)],
          },
        },
      },

      {
        $group: {
          _id: "$paidBy",
          totalPayment: {
            $sum: {
              $add: ["$leftAmount", "$paidAmount"],
            },
          },
          totalPaymentDoneSoFar: {
            $sum: "$paidAmount",
          },
          amountToBePaid: {
            $sum: "$leftAmount",
          },
          monthsRegistered: {
            $first: "$totalInstallment",
          },
          paidBy: {
            $first: "$paidBy",
          },
        },
      },
      {
        $addFields: {
          monthlyPayment: { $divide: ["$totalPayment", "$monthsRegistered"] },
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
      {
        $unwind: "$student",
      },
      {
        $lookup: {
          from: "payments",
          localField: "paidBy",
          foreignField: "paidBy",
          pipeline: [
            {
              $match: {
                paymentStatus: "paid",
              },
            },
            {
              $group: {
                _id: null,
                count: { $sum: 1 },
              },
            },
          ],

          as: "monthsPaid",
        },
      },
      {
        $unwind: { path: "$monthsPaid", preserveNullAndEmptyArrays: true },
      },
      {
        $project: {
          totalPayment: 1,
          totalPaymentDoneSoFar: 1,
          amountToBePaid: 1,
          monthsRegistered: 1,
          monthlyPayment: 1,
          studentName: "$student.name",
          monthsPaid: "$monthsPaid.count",
          payments: 1,
        },
      },
    ]);

    let payments = await Payment.find({
      paidBy: { $in: parent.children },
    })
      .sort("dueDate")
      .populate("paidBy");

    return res.status(200).json({
      summary: result,
      payments: payments.map((payment) => {
        return {
          paymentID: payment._id,
          studentName: payment.paidBy.name,
          status: payment.paymentStatus,
          dueDate: payment.dueDate,
          leftAmount: payment.leftAmount,
          month: monthMap.get(payment.dueDate.getMonth() + 1),
          postponedDays: 0,
          lateDays: 0,
          displayPayButton: payment.paymentStatus != "paid",
        };
      }),
    });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.showPaymentInfo = async (req, res) => {
  const { paymentID } = req.body;
  try {
    let payment = await Payment.findById(paymentID);

    let driverAccounts = await Account.find({
      phone: payment.paidTo,
    });

    return res.status(200).json(driverAccounts);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: User not found" });
    }
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
