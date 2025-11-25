const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const cors = require("cors");
const schedule = require("node-schedule");
const app = express();
require("dotenv").config();

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

app.use(bodyParser.json({ extended: true }));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

const { Driver } = require("./models/user");
const ShiftSchedule = require("./models/shiftSchedule");
const AgendaEntry = require("./models/agendaEntry");
const Payment = require("./models/payment");
const Student = require("./models/student");
const Subscription = require("./models/subscription");

app.get("/", (req, res) => {
  res.send("soCoolBus will rise here...");
});

// Routes

app.use("/login", require("./routes/login"));

/*
app.use(
	"/adminSchool",
	require("./routes/admin_routes/adminSchool")
);
app.use(
	"/adminBus",
	require("./routes/admin_routes/adminBus")
);**/

app.use("/driver", require("./routes/driver.js"));
app.use("/user", require("./routes/user.js"));
app.use("/parent", require("./routes/parent.js"));
app.use("/school", require("./routes/school.js"));
app.use("/student", require("./routes/student.js"));
app.use("/maps", require("./routes/maps.js"));
app.use("/shift", require("./routes/shift.js"));
app.use("/sms", require("./routes/sms.js"));
app.use("/permission", require("./routes/permission.js"));
app.use("/report", require("./routes/report.js"));
app.use("/adminPanel", require("./routes/adminPanel.js"));
app.use("/schoolAdministrator", require("./routes/schoolAdministrator.js"));
app.use("/companyAdmin", require("./routes/companyAdmin.js"));
app.use("/location", require("./routes/location.js"));

const PORT = process.env.PORT || 5001;
const DB_URL = process.env.DB_URL;

mongoose
  .set("strictQuery", false)
  .connect(DB_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    app.listen(PORT, () => {
      console.log(`App is listening on ${PORT}`);
    });
  })
  .catch((e) => {
    console.error(e.message);
    logtail.error(e.message);
  });

schedule.scheduleJob("shift-scheduler", "0 0 * * *", async () => {
  // This will run at every midnight
  console.log("Scheduling shifts for each driver...");
  try {
    const drivers = await Driver.find();
    for (let driver of drivers) {
      for (let school of driver.schools) {
        let shiftSchedule = new ShiftSchedule({
          driver: driver._id,
          school: school._id,
        });

        await shiftSchedule.save();
      }
    }
    console.log(
      "Scheduling is successful for date: " +
        new Date().toISOString().slice(0, 10)
    );
  } catch (error) {
    console.log("Error during scheduling shifts: " + error);
    logtail.error("Error during scheduling shifts: " + error);
    logtail.flush();
  }
  console.log("Late check for payments is about to start...");
  try {
    const updatedPayments = await Payment.find({
      paymentStatus: { $ne: "late" },
      dueDate: { $lte: new Date() },
    });

    for (let payment of updatedPayments) {
      let student = await Student.findById(payment.paidBy).populate("school");
      const agendaEntry = new AgendaEntry({
        driver: payment.paidTo,
        payment: payment._id,
        agendaEntryType: "PAYMENT",
        mainHeader: student.name,
        summary: "Ödeme Gecikti",
        detailedDescription:
          payment.leftAmount + "₺ tutarındaki ödeme gecikti.",
      });
      await agendaEntry.save();
    }

    await Payment.updateMany(
      {
        paymentStatus: { $ne: "late" },
        dueDate: { $lte: new Date() },
      },
      {
        $set: {
          paymentStatus: "late",
          statusChange: new Date(),
          lastUpdate: new Date(),
        },
      },
      { new: true }
    );

    console.log("Late check is successfully completed.");
  } catch (error) {
    console.log("Error during checking late payments: " + error);
    logtail.error("Error during checking late payments: " + error);
    logtail.flush();
    
  }

  console.log("Late check for subscriptions is about to start...");
  try {
    await Subscription.updateMany(
      {
        timeIsUp: false,
        ends: { $lte: new Date() },
      },
      {
        $set: {
          timeIsUp: true,
          lastChecked: new Date(),
        },
      }
    );

    console.log("Late check for subscriptions is successfully completed.");
  } catch (error) {
    console.log("Error during checking late subscriptions: " + error);
    logtail.error("Error during checking late subscriptions: " + error);
    logtail.flush();
  }
});
