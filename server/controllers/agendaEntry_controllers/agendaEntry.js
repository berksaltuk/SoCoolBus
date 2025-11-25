const AgendaEntry = require("../../models/agendaEntry");
const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.getAgendaEntries = async (req, res) => {
  // Only returns top 5 agenda entries
  try {
    var now = new Date();
    var startOfToday = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate()
    );

    const agendaEntries = await AgendaEntry.find({
      driver: req.body.driverPhone,
      date: {$gte: startOfToday}
    })
      .select({
        _id: 1,
        mainHeader: 1,
        summary: 1,
        detailedDescription: 1,
        date: 1,
      })
      .sort({date: "desc"})
      .limit(5);
    return res.status(200).send(agendaEntries);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
