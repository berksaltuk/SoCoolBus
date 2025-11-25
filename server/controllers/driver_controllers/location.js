const Location = require("../../models/location");
const Shift = require("../../models/shift");
const Student = require("../../models/student");
const { Parent } = require("../../models/user");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.sendLocation = async (req, res) => {
  try {
    const { shiftID, lat, lon } = req.body;

    let shift = await Shift.findById(shiftID);

    let location = await Location.findById(shift.currentLocation);

    location.lat = lat;
    location.lon = lon;
    location.updated_at = new Date();

    await location.save();

    return res.status(200).send(location);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getLocation = async (req, res) => {
  try {
    const { parentPhone } = req.body;

    let parent = await Parent.findOne({ phone: parentPhone });

    let result = await Student.aggregate([
      {
        $match: {
          _id: { $in: parent.children },
          onShift: true,
        },
      },
      {
        $lookup: {
          from: "locations",
          localField: "currentShift",
          foreignField: "shift",
          pipeline: [
            {
              $sort: {
                updated_at: -1,
              },
            },
            {
              $limit: 1,
            },
          ],
          as: "location",
        },
      },
      {
        $unwind: "$location",
      },
      {
        $project: {
          _id: 1,
          name: 1,
          lat: "$location.lat",
          lon: "$location.lon",
          lastUpdate: "$location.updated_at",
          currentShift: 1,
        },
      },
    ]);

    return res.status(200).send(result);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
