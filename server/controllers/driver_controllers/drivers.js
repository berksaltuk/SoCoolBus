const SchoolBus = require("../../models/schoolBus");
const { Driver, User } = require("../../models/user");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.tryDriver = async (req, res) => {
  try {
    return res.status(200).send({ isItWorking: true });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getSchoolsSingleDriver = async (req, res) => {
  try {
    let phone = req.body.phone;

    const driver = await Driver.findOne({ phone: phone }).populate("schools");

    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }

    return res.status(200).send(driver.schools);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
module.exports.getDriverByPhone = async (req, res) => {
  try {
    let phone = req.body.phone;

    const driver = await Driver.findOne({ phone: phone });

    if (!driver) {
      return res.status(404).send({
        success: false,
        errorMsg: "Driver with this phone does not exist.",
      });
    }

    return res.status(200).send(driver);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getAllDrivers = async (req, res) => {
  try {
    const drivers = await Driver.find({});

    if (!drivers) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "Driver does not exist." });
    }

    return res.status(200).send(drivers);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.deleteDriverByPhone = async (req, res) => {
  try {
    const driver = await Driver.findOne({ phone: req.params.phone });

    const user = await User.findOne({ phone: req.params.phone });

    if (!driver || !user) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "Driver is not found." });
    }
    await driver.remove();
    await user.remove();

    return res.status(200).send({ driverRemoved: true });
  } catch (error) {
    if (error.kind === "ObjectId") {
      return res.status(404).json({ msg: "Error: Driver not found" });
    }
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updateSchoolBus = async (req, res) => {
  const driver = await Driver.findOne({ phone: req.body.phone });
  let bus = driver.bus;
  SchoolBus.findOneAndUpdate(
    { _id: bus },
    {
      $set: {
        busModel: req.body.busModel,
        seatCount: req.body.seatCount,
        muayeneStarts: req.body.muayeneStarts,
        muayeneEnds: req.body.muayeneEnds,
        sigortaStarts: req.body.sigortaStarts,
        sigortaEnds: req.body.sigortaEnds,
      },
    },
    { new: true }
  )
    .then(() => {
      return res
        .status(200)
        .send({ msg: "School bus setting is updated successfully." });
    })
    .catch((error) => {
      console.error(error.message);
      logtail.error(error.message);
      logtail.flush();
      return res.status(500).send({ msg: "Server Error: " + error.message });
    });
};

module.exports.getSchoolBusByDriver = async (req, res) => {
  try {
    const driver = await Driver.findOne({ phone: req.body.phone });

    const bus = await SchoolBus.findById(driver.bus);

    return res.status(200).json(bus);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
