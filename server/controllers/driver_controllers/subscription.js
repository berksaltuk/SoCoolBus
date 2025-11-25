const Subscription = require("../../models/subscription");
const SubscriptionHistory = require("../../models/subscriptionHistory");
const { Driver } = require("../../models/user");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.startSubscription = async (req, res) => {
  try {
    const { driverPhone, schoolNumber, lengthInMonths } = req.body;

    let driver = await Driver.findOne({ phone: driverPhone });

    let subscription = await Subscription.findOne({ driver: driver._id });

    let subscriptionHistory = new SubscriptionHistory({
      driver: driver._id,
      starts: subscription.starts,
      ends: subscription.ends,
      maxSchoolNumber: subscription.maxSchoolNumber,
      subscriptionType: subscription.subscriptionType,
      subscriptionFee: subscription.subscriptionFee,
    });

    await subscriptionHistory.save();

    if ([1, 3, 6, 9].includes(lengthInMonths)) {
      return res
        .status(400)
        .json({ msg: "The length in months is not valid." });
    }

    if (driver.schools.length > schoolNumber) {
      return res.status(400).send({
        msg: "The school number must be more than your current number of schools added.",
      });
    }

    let cost = subscriptionFeeCalculator(schoolNumber, lengthInMonths);

    subscription.maxSchoolNumber = schoolNumber;

    if (!subscription.timeIsUp) {
      subscription.subscriptionFee += cost;
      if (subscription.subscriptionType == "TRIAL")
        subscription.lengthInMonths = lengthInMonths;
      else subscription.lengthInMonths += lengthInMonths;
      let endDate = new Date(subscription.ends);
      let subscriptionDaysAdded = new Date(
        endDate + lengthInMonths * 30 * 1000 * 86400
      );
      subscription.ends = subscriptionDaysAdded;
    } else {
      let now = new Date();
      let subscriptionDaysAdded = new Date(
        Date.now() + lengthInMonths * 30 * 1000 * 86400
      );
      subscription.lengthInMonths = lengthInMonths;
      subscription.starts = now;
      subscription.ends = subscriptionDaysAdded;
      subscription.subscriptionFee = cost;
    }
    subscription.subscriptionType = "PAID";
    subscription.timeIsUp = false;
    await subscription.save();

    return res
      .status(200)
      .json({ msg: "Your subscription is started successfully." });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.calculateSubscriptionCost = async (req, res) => {
  try {
    const { schoolNumber, lengthInMonths } = req.body;
    if ([1, 3, 9, 12].includes(lengthInMonths)) {
      return res
        .status(400)
        .json({ msg: "The length in months is not valid." });
    }
    return res
      .status(200)
      .json({ cost: subscriptionFeeCalculator(schoolNumber, lengthInMonths) });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

let subscriptionFeeCalculator = (schoolNumber, lengthInMonths) => {
  // Length in months can only be 1, 3, 9, or 12
  let costPerSchool =
    lengthInMonths === 12
      ? 15 * lengthInMonths
      : lengthInMonths === 9
      ? 20 * lengthInMonths
      : lengthInMonths === 3
      ? 25 * lengthInMonths
      : 30 * lengthInMonths;

  return costPerSchool * schoolNumber;
};

module.exports.getSubscriptionHistoryOfDriver = async (req, res) => {
  try {
    let driver = await Driver.findOne({ phone: req.body.driverPhone });

    let history = await SubscriptionHistory.find(
      { driver: driver._id },
      {
        subscriptionType: 1,
        subscriptionFee: 1,
        starts: 1,
        ends: 1,
        maxSchoolNumber: 1,
        lengthInMonths: 1,
      }
    );

    return res.status(200).json(history);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.calculateRemainingSubscriptionTime = async (req, res) => {
  try {
    const { driverPhone } = req.body;

    let driver = await Driver.findOne({ phone: driverPhone });

    let subscription = await Subscription.findOne({ driver: driver._id });

    if (subscription.timeIsUp) {
      return res
        .status(200)
        .json({ remanining: "Your subscription time has ended." });
    }
    let endDate = subscription.ends;
    let startDate = new Date();

    const timeDiff = Math.abs(endDate - startDate);

    // Convert milliseconds to seconds
    const seconds = Math.floor(timeDiff / 1000);

    // Calculate the remaining values
    let remainingSeconds = seconds % 60;
    let minutes = Math.floor(seconds / 60);
    let remainingMinutes = minutes % 60;
    let hours = Math.floor(minutes / 60);
    let remainingHours = hours % 24;
    let days = Math.floor(hours / 24);
    let remainingDays = days;

    // Calculate months and adjust remaining days
    let months = 0;
    while (remainingDays >= 30) {
      const monthStartDate = new Date(
        startDate.getFullYear(),
        startDate.getMonth() + months,
        1
      );
      const monthEndDate = new Date(
        startDate.getFullYear(),
        startDate.getMonth() + months + 1,
        0
      );
      const monthDays = Math.min(
        monthEndDate.getDate(),
        daysInMonth(monthStartDate)
      );
      remainingDays -= monthDays;
      if (remainingDays >= 0) {
        months++;
      }
    }

    // Helper function to get the number of days in a month
    function daysInMonth(date) {
      const year = date.getFullYear();
      const month = date.getMonth();
      return new Date(year, month + 1, 0).getDate();
    }

    // Calculate remaining hours, minutes, and seconds
    const remainingTime = timeDiff % (1000 * 60 * 60 * 24);
    remainingHours = Math.floor(remainingTime / (1000 * 60 * 60));
    const remainingTimeMinutes = remainingTime % (1000 * 60 * 60);
    remainingMinutes = Math.floor(remainingTimeMinutes / (1000 * 60));
    const remainingTimeSeconds = remainingTimeMinutes % (1000 * 60);
    remainingSeconds = Math.floor(remainingTimeSeconds / 1000);

    // Prepare the result object
    const result = {
      months: months > 0 ? months : null,
      days: remainingDays > 0 ? remainingDays : null,
      hours: remainingHours > 0 ? remainingHours : null,
      minutes: remainingMinutes > 0 ? remainingMinutes : null,
      seconds: remainingSeconds > 0 ? remainingSeconds : null,
    };

    return res.status(200).json({ remaining: result });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getSubscriptionDetails = async (req, res) => {
  try {
    let driver = await Driver.findOne({ phone: req.body.driverPhone });

    let subscription = await Subscription.findOne(
      { driver: driver._id },
      {
        subscriptionType: 1,
        subscriptionFee: 1,
        starts: 1,
        ends: 1,
        maxSchoolNumber: 1,
        timeIsUp: 1,
        lengthInMonths: 1,
      }
    );

    return res.status(200).json(subscription);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.addAdditionalSchool = async (req, res) => {
  try {
    let driver = await Driver.findOne({ phone: req.body.driverPhone });

    let subscription = await Subscription.findOne({ driver: driver._id });
    if (subscription.timeIsUp || subscription.subscriptionType === "TRIAL") {
      return res
        .status(400)
        .json({ remanining: "You should start a paid subscription first." });
    }
    let lengthInMonths = subscription.lengthInMonths;
    let additionalCost =
      lengthInMonths === 9
        ? 15
        : lengthInMonths === 6
        ? 20
        : lengthInMonths === 3
        ? 25
        : 30;

    let start = new Date();
    let end = new Date(subscription.ends);

    let yearDiff = end.getFullYear() - start.getFullYear();
    let monthDiff = end.getMonth() - start.getMonth();

    let numberOfMonthsLeft = yearDiff * 12 + monthDiff;

    let costPerSchool = additionalCost * numberOfMonthsLeft;

    subscription.maxSchoolNumber += req.body.additionalSchoolNumber;
    subscription.subscriptionFee +=
      costPerSchool * req.body.additionalSchoolNumber;

    await subscription.save();

    return res.status(200).json({ msg: "Schools are added." });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
